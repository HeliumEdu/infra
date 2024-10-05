terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  cloud {
    organization = "HeliumEdu"
    workspaces {
      name = "deploy-prod"
    }
  }

  required_version = ">= 1.2.0"
}