variable "environment" {
  description = "The environment"
  type        = string
}

variable "environment_prefix" {
  description = "Prefix used for env in hostnames (empty string when `prod`)"
  type        = string
}

variable "heliumedu_com_zone_id" {
  description = "For non-prod zones, this is used to link the env's subdomain in the parent domain"
  default     = null
}

variable "heliumedu_dev_zone_id" {
  description = "For non-prod zones, this is used to link the env's subdomain in the parent domain"
  default     = null
}

variable "heliumstudy_com_zone_id" {
  description = "For non-prod zones, this is used to link the env's subdomain in the parent domain"
  default     = null
}

variable "heliumstudy_dev_zone_id" {
  description = "For non-prod zones, this is used to link the env's subdomain in the parent domain"
  default     = null
}
