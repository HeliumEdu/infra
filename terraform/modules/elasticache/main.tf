resource "aws_elasticache_subnet_group" "helium" {
  name       = "helium"
  subnet_ids = [for id in var.subnet_ids : id]
}

resource "aws_elasticache_cluster" "helium" {
  cluster_id        = "helium"
  engine            = "redis"
  node_type         = "cache.t3.micro"
  num_cache_nodes   = 1
  engine_version    = "7.1"
  security_group_ids = [var.elasticache_sg]
  subnet_group_name = aws_elasticache_subnet_group.helium.name
}

# TODO: AWS doesn't give us a way to get an endpoint from the cluster, so will need to let Terraform provision, set env var, then run again