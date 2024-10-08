resource "aws_elasticache_subnet_group" "helium" {
  name       = "helium"
  subnet_ids = [for id in var.subnet_ids : id]
}

resource "aws_elasticache_cluster" "helium" {
  cluster_id        = "helium-${var.environment}"
  engine            = "redis"
  node_type         = "cache.t3.micro"
  num_cache_nodes   = 1
  engine_version    = "7.1"
  security_group_ids = [var.elasticache_sg]
  subnet_group_name = aws_elasticache_subnet_group.helium.name
}

output "elasticache_host" {
  value = aws_elasticache_cluster.helium.cache_nodes[0].address
}
