variable "environment" {
  description = "The environment"
  type        = string
}

variable "aws_region" {
  description = "The AWS region"
  type        = string
}

# Below are the variable definitions for values to be stored in the Secrets Manager

variable "smtp_email_user" {
  type = string
}

variable "smtp_email_password" {
  type = string
}