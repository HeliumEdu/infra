terraform {
  required_providers {
    datadog = {
      source  = "DataDog/datadog"
      version = "~> 3.38"
    }
  }
}

provider "datadog" {
  api_key = var.DD_API_KEY
  app_key = var.DD_APP_KEY
}
