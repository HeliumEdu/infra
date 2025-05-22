resource "aws_ecrpublic_repository" "repository_helium_frontend" {
  repository_name = "helium/frontend"

  catalog_data {
    architectures = ["x86-64"]
    description = "Frontend images for https://www.heliumedu.com"
    logo_image_blob = filebase64("${path.module}/logo.png")
    operating_systems = ["Linux"]
  }

  tags = {
    Environment = "N/A"
    Service     = "HeliumEdu"
  }
}

resource "aws_ecrpublic_repository" "repository_helium_platform_resource" {
  repository_name = "helium/platform-resource"

  catalog_data {
    architectures = ["x86-64"]
    description = "Base platform images for https://www.heliumedu.com"
    logo_image_blob = filebase64("${path.module}/logo.png")
    operating_systems = ["Linux"]
  }

  tags = {
    Environment = "N/A"
    Service   = "HeliumEdu"
  }
}

resource "aws_ecrpublic_repository" "repository_helium_platform_api" {
  repository_name = "helium/platform-api"

  catalog_data {
    architectures = ["x86-64"]
    description = "API platform images for https://www.heliumedu.com"
    logo_image_blob = filebase64("${path.module}/logo.png")
    operating_systems = ["Linux"]
  }

  tags = {
    Environment = "N/A"
    Service   = "HeliumEdu"
  }
}

resource "aws_ecrpublic_repository" "repository_helium_platform_worker" {
  repository_name = "helium/platform-worker"

  catalog_data {
    architectures = ["x86-64"]
    description = "Worker platform images for https://www.heliumedu.com"
    logo_image_blob = filebase64("${path.module}/logo.png")
    operating_systems = ["Linux"]
  }

  tags = {
    Environment = "N/A"
    Service   = "HeliumEdu"
  }
}