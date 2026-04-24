variable "helium_version" {
  description = "The container versions to deploy"
}

variable "default_arch" {
  description = "The target arch of container builds"
  type        = string
}

variable "platform_host_count" {
  description = "The initial number of platform API hosts desired in the cluster"
  type        = number
}

variable "platform_host_min" {
  description = "Minimum number of platform API hosts for autoscaling"
  type        = number
  default     = 1
}

variable "platform_host_max" {
  description = "Maximum number of platform API hosts for autoscaling"
  type        = number
  default     = 2
}

variable "celery_concurrency" {
  description = "Number of concurrent Celery worker processes per task"
  type        = number
  default     = 2
}

variable "platform_worker_count" {
  description = "The initial number of platform worker hosts desired in the cluster"
  type        = number
}

variable "platform_worker_min" {
  description = "Minimum number of platform worker hosts for autoscaling"
  type        = number
  default     = 1
}

variable "platform_worker_max" {
  description = "Maximum number of platform worker hosts for autoscaling"
  type        = number
  default     = 1
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

variable "subnet_ids" {
  description = "The list of subnets"
  type        = list(string)
}

variable "http_platform" {
  description = "The HTTP platform security group"
  type        = string
}

variable "platform_target_group" {
  description = "The platform LB target group"
  type        = string
}

variable "datadog_api_key" {
  description = "DataDog API key for DogStatsD sidecar"
  type        = string
  sensitive   = true
}

variable "request_timeout_seconds" {
  description = "Max request duration in seconds. Health check grace period is derived as 2x this value."
  type        = number
  default     = 60
}