terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.18"
    }
  }
  cloud {
    organization = "HeliumEdu"
    workspaces {
      name = "dev-local"
    }
  }

  required_version = ">= 1.5.0"
}