resource "aws_elasticache_subnet_group" "helium" {
  name       = "helium-${var.environment}"
  subnet_ids = [for id in var.subnet_ids : id]
}

resource "aws_elasticache_cluster" "helium" {
  cluster_id        = "helium-${var.environment}"
  engine            = "redis"
  node_type         = var.instance_size
  num_cache_nodes   = var.num_cache_nodes
  engine_version    = "7.1"
  security_group_ids = [var.elasticache_sg]
  subnet_group_name = aws_elasticache_subnet_group.helium.name
}
