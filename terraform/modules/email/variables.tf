variable "environment" {
  description = "The environment"
  type        = string
}

variable "route53_heliumedu_com_zone_id" {
  description = "The Route 53 Zone ID"
  type        = string
}

variable "dkim_public_key" {
  description = "The DKIM public key"
  type        = string
}
