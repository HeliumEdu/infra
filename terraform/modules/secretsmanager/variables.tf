variable "environment" {
  description = "The environment"
  type        = string
}

variable "aws_region" {
  description = "The AWS region"
  type        = string
}

variable "aws_account_id" {
  description = "The AWS account ID"
  type        = string
}

variable "task_execution_role_arn" {
  description = "The Task execution role ARN"
  type        = string
}

# Below are the variable definitions for values to be stored in the Secrets Manager

variable "smtp_email_user" {
  type = string
}

variable "smtp_email_password" {
  type = string
}

variable "twilio_account_sid" {
  type = string
}

variable "twilio_auth_token" {
  type = string
}

variable "twilio_phone_number" {
  type = string
}

variable "s3_user_access_key_id" {
  type = string
}

variable "s3_user_secret_access_key" {
  type = string
}

variable "redis_host" {
  type = string
}

variable "db_host" {
  type = string
}

variable "db_user" {
  type = string
}

variable "db_password" {
  type = string
}

variable "datadog_api_key" {
  type = string
}

variable "platform_sentry_dsn" {
  type = string
}

variable "firebase_project_id" {
  type = string
}

variable "firebase_private_key_id" {
  type = string
}

variable "firebase_private_key" {
  type = string
}

variable "firebase_client_email" {
  type = string
}

variable "firebase_client_id" {
  type = string
}

variable "firebase_client_x509_cert_url" {
  type = string
}
