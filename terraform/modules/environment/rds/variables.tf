variable "environment" {
  description = "The environment"
  type        = string
}

variable "subnet_ids" {
  description = "The list of subnets"
  type        = list(string)
}

variable "mysql_sg" {
  description = "The MySQL security group"
  type        = string
}

variable "multi_az" {
  description = "True if DB should be multi-AZ"
  type        = bool
}

variable "instance_size" {
  description = "Instance size for DB"
  type        = string
}
