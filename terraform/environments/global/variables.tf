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
