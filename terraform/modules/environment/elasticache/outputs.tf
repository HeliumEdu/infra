output "elasticache_host" {
  value = aws_elasticache_replication_group.helium.primary_endpoint_address
}

output "elasticache_auth_token" {
  value     = random_password.auth_token.result
  sensitive = true
}