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

variable "helium_area_code" {
  description = "The area code for the Helium phone number"
  type        = string
  default     = "815"
}

variable "ci_area_code" {
  description = "The area code for the CI phone number"
  type        = string
  default     = "815"
}

### Variables defined below this point must have their defaults defined in the Terraform Workspace

variable "AWS_ACCESS_KEY_ID" {
  description = "The AWS access key ID"
}

variable "AWS_SECRET_ACCESS_KEY" {
  description = "The AWS secret access key"
}

variable "TWILIO_ACCOUNT_SID" {
  description = "The Twilio account SID"
}

variable "TWILIO_AUTH_TOKEN" {
  description = "The Twilio auth token"
}

variable "helium_twiml_handler_url" {
  description = "The URL for the TwiML Bin"
}

variable "ci_twiml_handler_url" {
  description = "The URL for the TwiML Bin"
}