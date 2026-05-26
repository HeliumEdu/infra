terraform {
  required_providers {
    twilio = {
      source  = "twilio/twilio"
      version = "0.18.46"
    }
  }

  required_version = ">= 1.5.0"
}