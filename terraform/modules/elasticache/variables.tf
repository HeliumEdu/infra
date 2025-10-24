variable "environment" {
  description = "The environment"
  type        = string
}

variable "subnet_ids" {
  description = "The list of subnets"
  type        = list(string)
}

variable "elasticache_sg" {
  description = "The MySQL security group"
  type        = string
}

variable "num_cache_nodes" {
  description = "The number of cache nodes"
  type        = number
}

variable "instance_size" {
  description = "Instance size for cache"
  type        = string
}
