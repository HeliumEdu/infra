variable "environment" {
  description = "The environment"
  type        = string
}

variable "route53_heliumedu_com_zone_id" {
  description = "The Route 53 zone ID"
  type        = string
}

variable "route53_heliumedu_com_zone_name" {
  description = "The Route 53 zone name"
  type        = string
}

variable "security_group" {
  description = "The http/s security group ID"
  type        = string
}

variable "subnet_ids" {
  description = "The list of subnets"
  type        = list(string)
}

variable "helium_vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "heliumedu_com_cert_arn" {
  description = "The ARN of the <env>heliumedu.com SSL certificate"
  type        = string
}
