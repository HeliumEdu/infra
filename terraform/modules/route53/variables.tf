variable "environment" {
  description = "The environment"
  type        = string
}

variable "environment_prefix" {
  description = "Prefix used for env in hostnames (empty string when `prod`)"
  type        = string
}

variable "parent_com_zone_id" {
  description = "For non-prod zones, this is used to link the env's subdomain in the parent domain"
  default     = null
}

variable "parent_dev_zone_id" {
  description = "For non-prod zones, this is used to link the env's subdomain in the parent domain"
  default     = null
}
