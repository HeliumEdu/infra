variable "environment" {
  description = "Environment name (dev, prod)."
  type        = string
}

variable "environment_prefix" {
  description = "Subdomain prefix per env. Empty for prod, '<env>.' otherwise (e.g., 'dev.')."
  type        = string
}

variable "route53_heliumedu_com_zone_id" {
  type = string
}

variable "route53_heliumedu_com_zone_name" {
  description = "Zone apex (e.g., 'heliumedu.com' for prod, 'heliumedu.dev' for dev)."
  type        = string
}

variable "heliumedu_com_cert_arn" {
  description = "ACM cert ARN covering landing.${environment_prefix}${zone_name}. Add the SAN to the cert in modules/environment/certificatemanager."
  type        = string
}

variable "is_landing_alias_enabled" {
  description = "Pre-cutover: serve at landing.* with a dedicated distribution. Post-cutover (2026-08-01): set to false and repoint the legacy `www.heliumedu.com` CloudFront origin in the cloudfront module to this bucket."
  type        = bool
  default     = true
}
