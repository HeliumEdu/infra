terraform {
  cloud {
    organization = "HeliumEdu"

    workspaces {
      name = "global"
    }
  }

  required_version = ">= 1.11.0"
}
