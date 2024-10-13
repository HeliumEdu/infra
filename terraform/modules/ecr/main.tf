resource "aws_ecr_repository" "repository_helium_frontend" {
  name                 = "helium/frontend"
  image_tag_mutability = "MUTABLE"
}

output "frontend_repository_uri" {
  value = aws_ecr_repository.repository_helium_frontend.repository_url
}

resource "aws_ecr_repository" "repository_helium_platform_resource" {
  name                 = "helium/platform-resource"
  image_tag_mutability = "MUTABLE"
}

output "platform_resource_repository_uri" {
  value = aws_ecr_repository.repository_helium_platform_resource.repository_url
}

resource "aws_ecr_repository" "repository_helium_platform_api" {
  name                 = "helium/platform-api"
  image_tag_mutability = "MUTABLE"
}

output "platform_api_repository_uri" {
  value = aws_ecr_repository.repository_helium_platform_api.repository_url
}

resource "aws_ecr_repository" "repository_helium_platform_worker" {
  name                 = "helium/platform-worker"
  image_tag_mutability = "MUTABLE"
}

output "platform_worker_repository_uri" {
  value = aws_ecr_repository.repository_helium_platform_worker.repository_url
}