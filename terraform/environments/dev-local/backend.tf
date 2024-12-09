terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.1"
    }
  }
  cloud {
    organization = "HeliumEdu"
    workspaces {
      name = "dev-local"
    }
  }

  required_version = ">= 1.2.0"
}