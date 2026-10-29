variable "environment" {
  description = "The environment"
  type        = string
}

variable "connector_version" {
  description = "The connector version (the Lambda and its distribution aren't created until it's set)"
  type        = string
  default     = null
}

variable "mcp_heliumedu_com_cert_arn" {
  description = "The ARN of the mcp.<env>heliumedu.com SSL certificate"
  type        = string
}

variable "route53_heliumedu_com_zone_id" {
  description = "The Route 53 Zone ID"
  type        = string
}

variable "route53_heliumedu_com_zone_name" {
  description = "The Route 53 zone name"
  type        = string
}

variable "cloudfront_logs_bucket_domain_name" {
  description = "The domain name of the bucket CloudFront access logs go to"
  type        = string
}

variable "muppets_response_headers_policy_id" {
  description = "The CloudFront response headers policy every distribution uses"
  type        = string
}

variable "request_timeout_seconds" {
  description = "How long a request may take, in seconds"
  type        = number
}
