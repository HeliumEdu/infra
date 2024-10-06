variable "environment" {
  description = "The environment"
  type        = string
}

variable "subnet_ids" {
  description = "The list of subnets"
  type = list(string)
}

variable "elasticache_sg" {
  description = "The MySQL security group"
}