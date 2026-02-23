variable "environment" {
  description = "The environment"
  type        = string
}

variable "environment_prefix" {
  description = "Prefix used for env in hostnames (empty string when `prod`)"
  type        = string
}

variable "heliumedu_com_cert_arn" {
  description = "The ARN of the <env>heliumedu.com SSL certificate"
  type        = string
}

variable "heliumstudy_com_cert_arn" {
  description = "The ARN of the <env>heliumstudy.com SSL certificate"
  type        = string
}

variable "s3_bucket" {
  description = "The S3 bucket to host"
  type        = string
}

variable "s3_website_endpoint" {
  default = "The endpoint for the S3 site"
}

variable "s3_frontend_app_bucket" {
  description = "The S3 bucket for the Flutter app frontend"
  type        = string
}

variable "s3_frontend_app_website_endpoint" {
  description = "The endpoint for the Flutter app frontend S3 site"
  type        = string
}

variable "route53_heliumedu_com_zone_id" {
  description = "The Route 53 Zone ID"
  type        = string
}

variable "route53_heliumedu_com_zone_name" {
  description = "The Route 53 zone name"
  type        = string
}

variable "route53_heliumstudy_com_zone_id" {
  description = "The Route 53 Zone ID"
  type        = string
}

variable "route53_heliumstudy_com_zone_name" {
  description = "The Route 53 zone name"
  type        = string
}
