resource "awscc_ecr_repository" "repository_helium_frontend" {
  repository_name      = "helium/frontend"
  image_tag_mutability = "MUTABLE"
}

resource "awscc_ecr_repository" "repository_helium_platform_api" {
  repository_name      = "helium/platform-api"
  image_tag_mutability = "MUTABLE"
}

resource "awscc_ecr_repository" "repository_helium_platform_worker" {
  repository_name      = "helium/platform-worker"
  image_tag_mutability = "MUTABLE"
}