locals {
  about_text          = "Helium is an online student planner that lets you organize and color-coordinate your schedule and schoolwork, capture details about every assignment, and plan your study time efficiently. Check it out at https://www.heliumedu.com."
  platform_usage_text = "Helium is open source, and usage details for this image be found at https://github.com/heliumedu/platform."
}

resource "aws_ecrpublic_repository" "repository_helium_frontend" {
  repository_name = "helium/frontend"

  catalog_data {
    operating_systems = ["Linux"]
    architectures     = ["x86-64"]
    logo_image_blob   = filebase64("${path.module}/../../resources/logo.png")
    description       = "Images for the frontend-legacy containers."
    about_text        = local.about_text
    usage_text        = "HeliumEdu is open source, and usage details for this image be found at https://github.com/heliumedu/frontend-legacy."
  }

  tags = {
    Environment = "N/A"
    Service     = "HeliumEdu"
  }
}

resource "aws_ecr_lifecycle_policy" "frontend_untagged_expiration_policy" {
  repository = aws_ecrpublic_repository.repository_helium_frontend.id
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Expire untagged images",
        selection = {
          tagStatus   = "untagged",
          countType   = "sinceImagePushed",
          countUnit   = "days",
          countNumber = 1
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_ecrpublic_repository" "repository_helium_frontend_web" {
  repository_name = "helium/frontend-web"

  catalog_data {
    operating_systems = ["Linux"]
    architectures     = ["x86-64"]
    logo_image_blob   = filebase64("${path.module}/../../resources/logo.png")
    description       = "Images for the frontend web containers."
    about_text        = local.about_text
    usage_text        = "HeliumEdu is open source, and usage details for this image be found at https://github.com/heliumedu/frontend."
  }

  tags = {
    Environment = "N/A"
    Service     = "HeliumEdu"
  }
}

resource "aws_ecrpublic_repository" "repository_helium_platform_resource" {
  repository_name = "helium/platform-resource"

  catalog_data {
    operating_systems = ["Linux"]
    architectures     = ["x86-64"]
    logo_image_blob   = filebase64("${path.module}/../../resources/logo.png")
    description       = "Images for the platform's resource containers (short-lived data provisioning)."
    about_text        = local.about_text
    usage_text        = local.platform_usage_text
  }

  tags = {
    Environment = "N/A"
    Service     = "HeliumEdu"
  }
}

resource "aws_ecr_lifecycle_policy" "resource_untagged_expiration_policy" {
  repository = aws_ecrpublic_repository.repository_helium_platform_resource.id
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Expire untagged images",
        selection = {
          tagStatus   = "untagged",
          countType   = "sinceImagePushed",
          countUnit   = "days",
          countNumber = 1
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_ecrpublic_repository" "repository_helium_platform_api" {
  repository_name = "helium/platform-api"

  catalog_data {
    operating_systems = ["Linux"]
    architectures     = ["x86-64"]
    logo_image_blob   = filebase64("${path.module}/../../resources/logo.png")
    description       = "Images for the platform's API containers."
    about_text        = local.about_text
    usage_text        = local.platform_usage_text
  }

  tags = {
    Environment = "N/A"
    Service     = "HeliumEdu"
  }
}

resource "aws_ecr_lifecycle_policy" "api_untagged_expiration_policy" {
  repository = aws_ecrpublic_repository.repository_helium_platform_api.id
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Expire untagged images",
        selection = {
          tagStatus   = "untagged",
          countType   = "sinceImagePushed",
          countUnit   = "days",
          countNumber = 1
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_ecrpublic_repository" "repository_helium_platform_worker" {
  repository_name = "helium/platform-worker"

  catalog_data {
    operating_systems = ["Linux"]
    architectures     = ["x86-64"]
    logo_image_blob   = filebase64("${path.module}/../../resources/logo.png")
    description       = "Image's for the platform's Worker containers."
    about_text        = local.about_text
    usage_text        = local.platform_usage_text
  }

  tags = {
    Environment = "N/A"
    Service     = "HeliumEdu"
  }
}

resource "aws_ecr_lifecycle_policy" "worker_untagged_expiration_policy" {
  repository = aws_ecrpublic_repository.repository_helium_platform_worker.id
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Expire untagged images",
        selection = {
          tagStatus   = "untagged",
          countType   = "sinceImagePushed",
          countUnit   = "days",
          countNumber = 1
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}
