terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.18"
    }
    datadog = {
      source  = "DataDog/datadog"
      version = "~> 3.38"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.65"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY

  default_tags {
    tags = {
      Environment = "global"
      Terraform   = true
    }
  }
}

provider "datadog" {
  api_key = var.DD_API_KEY
  app_key = var.DD_APP_KEY
}

provider "tfe" {
  token = var.TERRAFORM_API_TOKEN
}
