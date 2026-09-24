variable "aws_account_id" {
  description = "The AWS account ID where Helium infrastructure is deployed"
  type        = string
}

variable "github_pat" {
  description = "Fine-grained GitHub personal access token with Actions write access to HeliumEdu repositories"
  type        = string
  sensitive   = true
}
