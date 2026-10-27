variable "environment" {
  description = "The environment"
  type        = string
}

variable "route53_heliumedu_com_zone_name" {
  description = "The Route 53 zone name"
  type        = string
}

variable "helium_vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "heliumedu_com_cert_arn" {
  description = "The ARN of the <env>heliumedu.com SSL certificate"
  type        = string
}

variable "alb_access_logs_bucket" {
  description = "The S3 bucket name for ALB access logs"
  type        = string
}

variable "request_timeout_seconds" {
  description = "Max request duration in seconds. Used for deregistration delay."
  type        = number
  default     = 60
}

variable "private_subnet_ids" {
  description = "The list of private subnets"
  type        = list(string)
}

variable "api_security_group" {
  description = "The API security group ID"
  type        = string
}
