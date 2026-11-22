locals {
  # Who hears about each alert tier, and when. Down is a hard outage or a release that broke the product, Degraded is
  # partial or slow service that only matters if it persists, Info is visible in Datadog only. Escalation (recipients,
  # timing, paging) changes here, never in individual monitors. Down monitors carry no warning threshold, since a
  # warning is a degradation.
  triage = {
    down     = { recipients = ["@alerts@heliumedu.com"], notify_after_minutes = 0, notify_on_recovery = true, priority = 1 }
    degraded = { recipients = ["@alerts@heliumedu.com"], notify_after_minutes = 60, notify_on_recovery = false, priority = 3 }
    info     = { recipients = [], notify_after_minutes = 0, notify_on_recovery = false, priority = 5 }
  }

  notify = {
    for tier, policy in local.triage : tier => {
      label    = "[${title(tier)}]"
      priority = policy.priority
      message = length(policy.recipients) == 0 ? "" : join("", concat(
        policy.notify_after_minutes > 0 ? [] : [
          for status in ["is_alert", "is_no_data"] : "{{#${status}}}Notify: ${join(" ", policy.recipients)}{{/${status}}}"
        ],
        policy.notify_on_recovery ? ["{{#is_recovery}}Notify: ${join(" ", policy.recipients)}{{/is_recovery}}"] : [],
      ))
      escalation_message = length(policy.recipients) > 0 && policy.notify_after_minutes > 0 ? (
        "Unresolved for ${policy.notify_after_minutes} minutes. Notify: ${join(" ", policy.recipients)}"
      ) : null
      renotify_interval    = length(policy.recipients) > 0 && policy.notify_after_minutes > 0 ? policy.notify_after_minutes : null
      renotify_occurrences = length(policy.recipients) > 0 && policy.notify_after_minutes > 0 ? 1 : null
      renotify_statuses    = length(policy.recipients) > 0 && policy.notify_after_minutes > 0 ? ["alert", "no data"] : null
    }
  }
}
