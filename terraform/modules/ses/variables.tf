variable "environment" {
  description = "The environment"
  type        = string
}

variable "aws_region" {
  description = "The AWS region"
  type        = string
}

variable "heliumedu_s3_bucket_name" {
  description = "The S3 bucket to store CI emails"
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

variable "route53_heliumedu_dev_zone_id" {
  description = "The Route 53 Zone ID"
  type        = string
}

variable "route53_heliumedu_dev_zone_name" {
  description = "The Route 53 zone name"
  type        = string
}
