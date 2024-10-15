output "frontend_repository_uri" {
  value = aws_ecr_repository.repository_helium_frontend.repository_url
}

output "platform_resource_repository_uri" {
  value = aws_ecr_repository.repository_helium_platform_resource.repository_url
}

output "platform_api_repository_uri" {
  value = aws_ecr_repository.repository_helium_platform_api.repository_url
}

output "platform_worker_repository_uri" {
  value = aws_ecr_repository.repository_helium_platform_worker.repository_url
}