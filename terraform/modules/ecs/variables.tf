variable "helium_version" {
  description = "The container versions to deploy"
}

variable "default_arch" {
  description = "The target arch of container builds"
  type        = string
}

variable "platform_host_count" {
  description = "The number of platform hosts desired in the cluster"
  type        = number
}

variable "platform_resource_repository_uri" {
  description = "Platform Resource container repo URI"
}

variable "platform_api_repository_uri" {
  description = "Platform API container repo URI"
}

variable "platform_worker_repository_uri" {
  description = "Platform Worker container repo URI"
}

variable "environment" {
  description = "The environment"
  type        = string
}

variable "environment_prefix" {
  description = "Prefix used for env in hostnames (empty string when `prod`)"
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

variable "datadog_api_key" {
  description = "The DataDog API key"
  type        = string
}

variable "subnet_ids" {
  description = "The list of subnets"
  type = list(string)
}

variable "http_platform" {
  description = "The HTTP platform security group"
  type        = string
}

variable "platform_target_group" {
  description = "The platform LB target group"
  type        = string
}