output "elasticache_host" {
  value = aws_elasticache_replication_group.helium.primary_endpoint_address
}