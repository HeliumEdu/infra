terraform {
  cloud {
    organization = "HeliumEdu"

    workspaces {
      name = "global"
    }
  }

  required_version = ">= 1.5.0"
}
