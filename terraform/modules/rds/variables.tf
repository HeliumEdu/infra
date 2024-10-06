variable "environment" {
  description = "The environment"
  type        = string
}

variable "subnet_ids" {
  description = "The list of subnets"
  type = list(string)
}

variable "username" {
  description = "The DB username"
}

variable "password" {
  description = "The DB password"
}

variable "mysql_sg" {
  description = "The MySQL security group"
}