output "frontend_repository_uri" {
  value = aws_ecrpublic_repository.repository_helium_frontend.repository_uri
}

output "frontend_web_repository_uri" {
  value = aws_ecrpublic_repository.repository_helium_frontend_web.repository_uri
}

output "platform_resource_repository_uri" {
  value = aws_ecrpublic_repository.repository_helium_platform_resource.repository_uri
}

output "platform_api_repository_uri" {
  value = aws_ecrpublic_repository.repository_helium_platform_api.repository_uri
}

output "platform_worker_repository_uri" {
  value = aws_ecrpublic_repository.repository_helium_platform_worker.repository_uri
}
