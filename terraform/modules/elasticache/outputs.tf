output "elasticache_host" {
  value = aws_elasticache_cluster.helium.cache_nodes[0].address
}