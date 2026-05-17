variable "environment" {
  description = "The environment"
  default     = "dev-local"
}

variable "environment_prefix" {
  description = "Prefix used for env in hostnames (empty string when `prod`)"
  default     = "dev-local."
}

variable "aws_region" {
  description = "The AWS region"
  default     = "us-east-2"
}

variable "heliumedu_com_zone_id" {
  description = "For non-prod zones, this is used to link the env's subdomain in the parent domain"
}

variable "heliumedu_dev_zone_id" {
  description = "For non-prod zones, this is used to link the env's subdomain in the parent domain"
}

variable "heliumstudy_com_zone_id" {
  description = "For non-prod zones, this is used to link the env's subdomain in the parent domain"
}

variable "heliumstudy_dev_zone_id" {
  description = "For non-prod zones, this is used to link the env's subdomain in the parent domain"
}

### Variables defined below this point must have their defaults defined in the Terraform Workspace

variable "AWS_ACCESS_KEY_ID" {
  description = "The AWS access key ID"
}

variable "AWS_SECRET_ACCESS_KEY" {
  description = "The AWS secret access key"
}

