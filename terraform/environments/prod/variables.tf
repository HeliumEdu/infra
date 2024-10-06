variable "helium_version" {
  description = "The container versions to deploy"
  default     = "1.7.0"
}

variable "environment" {
  description = "The environment"
  default     = "prod"
}

variable "environment_prefix" {
  description = "Prefix used for env in hostnames (empty string when `prod`)"
  default     = ""
}

variable "aws_region" {
  description = "The AWS region"
  default     = "us-east-1"
}

### Variables defined below this point must have their defaults defined in the Terraform Workspace

variable "AWS_ACCESS_KEY_ID" {
  description = "The AWS access key ID"
}

variable "AWS_SECRET_ACCESS_KEY" {
  description = "The AWS secret access key"
}

variable "aws_account_id" {
  description = "The AWS account ID"
}

variable "helium_twiml_handler_url" {
  description = "The URL for the TwiML Bin"
}

variable "ci_twiml_handler_url" {
  description = "The URL for the TwiML Bin"
}

variable "DD_API_KEY" {
  description = "The DataDog API key"
}

variable "DD_APP_KEY" {
  description = "The DataDog app key"
}

variable "PLATFORM_DB_USER" {
  description = "The MySQL DB username"
}

variable "PLATFORM_DB_PASSWORD" {
  description = "The MySQL DB password"
}

variable "PLATFORM_SECRET_PROD" {
  description = "The Django secret"
}

variable "ROLLBAR_API_KEY" {
  description = "The Rollbar API key"
}

variable "TWILIO_ACCOUNT_SID" {
  description = "The Twilio account SID"
}

variable "TWILIO_AUTH_TOKEN" {
  description = "The Twilio auth token"
}

# TODO: ideally we find a way to get these through outputs from the modules so we don't have to run apply twice, but for now defining them here
variable "PLATFORM_REDIS_HOST" {
  description = "Redis host"
}
variable "PLATFORM_DB_HOST" {
  description = "MySQL host"
}