variable "environment" {
  description = "The environment"
  type        = string
}

variable "aws_region" {
  description = "The AWS region"
  type        = string
}

variable region_azs {
  description = "Map of AZ details"
  type = map(map(string))
}