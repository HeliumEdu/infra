resource "aws_elasticache_subnet_group" "helium" {
  name       = "helium-${var.environment}"
  subnet_ids = [for id in var.subnet_ids : id]
}

resource "aws_elasticache_replication_group" "helium" {
  replication_group_id = "helium-${var.environment}"
  description          = "Helium ${var.environment} cache"
  engine               = "valkey"
  engine_version       = "7.2"
  node_type            = var.instance_size
  num_cache_clusters   = var.num_cache_nodes
  port                 = 6379

  security_group_ids = [var.elasticache_sg]
  subnet_group_name  = aws_elasticache_subnet_group.helium.name

  maintenance_window         = "sat:09:00-sat:10:00"
  auto_minor_version_upgrade = true

  automatic_failover_enabled = false
  multi_az_enabled           = false
}
