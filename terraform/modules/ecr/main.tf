resource "aws_ecr_repository" "repository_helium_frontend" {
  name                 = "helium/frontend"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "repository_helium_platform_resource" {
  name                 = "helium/platform-resource"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "repository_helium_platform_api" {
  name                 = "helium/platform-api"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "repository_helium_platform_worker" {
  name                 = "helium/platform-worker"
  image_tag_mutability = "MUTABLE"
}