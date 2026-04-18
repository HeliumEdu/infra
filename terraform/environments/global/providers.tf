terraform {
  required_providers {
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

provider "datadog" {
  api_key = var.DD_API_KEY
  app_key = var.DD_APP_KEY
}

provider "tfe" {
  token = var.TERRAFORM_API_TOKEN
}
