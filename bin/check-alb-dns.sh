#!/usr/bin/env bash
#
# Compares the addresses a load balancer advertises in DNS against the addresses
# attached to its interfaces. AWS exposes no API for the advertised set, so DNS
# is the only source of truth.
#
# Usage: check-alb-dns.sh [load-balancer-name]

set -euo pipefail

LB_NAME="${1:-${LB_NAME:-helium-prod}}"
RESOLVER="${RESOLVER:-}"
ORPHAN_RECHECK_SECONDS="${ORPHAN_RECHECK_SECONDS:-90}"

dig_cmd() {
  if [ -n "$RESOLVER" ]; then
    dig +short "$1" "$2" "@${RESOLVER}"
  else
    dig +short "$1" "$2"
  fi
}

LB_DNS=$(aws elbv2 describe-load-balancers \
  --names "$LB_NAME" \
  --query 'LoadBalancers[0].DNSName' \
  --output text)

if [ -z "$LB_DNS" ] || [ "$LB_DNS" = "None" ]; then
  echo "Could not resolve a DNS name for load balancer '$LB_NAME'." >&2
  exit 2
fi

resolve_advertised() {
  dig_cmd "$LB_DNS" A | { grep -E '^[0-9]+\.' || true; } | sort -u
}

advertised=$(resolve_advertised)

attached=$(aws ec2 describe-network-interfaces \
  --filters "Name=description,Values=ELB app/${LB_NAME}/*" \
  --query 'NetworkInterfaces[].Association.PublicIp' \
  --output text | tr '\t' '\n' | { grep -E '^[0-9]+\.' || true; } | sort -u)

if [ -z "$advertised" ]; then
  echo "$LB_DNS returned no A records." >&2
  exit 2
fi

if [ -z "$attached" ]; then
  echo "No ELB network interfaces found for '$LB_NAME'." >&2
  exit 2
fi

orphaned=$(comm -23 <(echo "$advertised") <(echo "$attached"))

if [ -n "$orphaned" ]; then
  echo "Advertised addresses with no interface; re-resolving in ${ORPHAN_RECHECK_SECONDS}s to rule out a stale cache."
  sleep "$ORPHAN_RECHECK_SECONDS"
  advertised=$(resolve_advertised)
  orphaned=$(comm -12 <(echo "$orphaned") <(echo "$advertised"))
fi

unadvertised=$(comm -13 <(echo "$advertised") <(echo "$attached"))

echo "Load balancer: $LB_NAME ($LB_DNS)"
echo "Advertised in DNS:"
echo "$advertised" | sed 's/^/  /'
echo "Attached to interfaces:"
echo "$attached" | sed 's/^/  /'

status=0

if [ -n "$orphaned" ]; then
  echo
  echo "ORPHANED - advertised with no interface behind them:"
  echo "$orphaned" | sed 's/^/  /'
  echo "Clients resolving these will hang until they time out."
  status=1
fi

if [ -n "$unadvertised" ]; then
  echo
  echo "UNADVERTISED - attached but absent from DNS:"
  echo "$unadvertised" | sed 's/^/  /'
  echo "These nodes are healthy but receiving no traffic."
  status=1
fi

if [ "$status" -eq 0 ]; then
  echo
  echo "DNS and interfaces agree."
else
  echo
  echo "Recovery: see docs/helium-alb-dns.md"
fi

echo
echo "orphaned_count=$(echo "$orphaned" | grep -c '^[0-9]' || true)"
echo "unadvertised_count=$(echo "$unadvertised" | grep -c '^[0-9]' || true)"

exit "$status"
