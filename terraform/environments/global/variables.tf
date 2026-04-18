variable "DD_API_KEY" {
  description = "The DataDog API key for sending metrics"
  type        = string
  sensitive   = true
}

variable "DD_APP_KEY" {
  description = "The DataDog Application key for managing resources"
  type        = string
  sensitive   = true
}

variable "aws_account_id" {
  description = "The AWS account ID where Helium infrastructure is deployed"
  type        = string
  sensitive   = true
}

variable "dev_env_enabled" {
  description = "Mirror of the dev workspace's env_enabled. When true, a run failure notification is created for the dev workspace."
  type        = bool
  default     = false
}

variable "TERRAFORM_API_TOKEN" {
  description = "HCP Terraform team token used to manage workspace notification configurations"
  type        = string
  sensitive   = true
}
