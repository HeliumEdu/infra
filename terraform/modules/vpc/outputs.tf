output "vpc_id" {
  value = aws_vpc.helium_vpc.id
}

output "subnet_ids" {
  value = [for subnet in aws_subnet.subnets : subnet.id]
}

output "http_s_sg_id" {
  value = aws_security_group.http_s.id
}

output "http_sg_platform" {
  value = aws_security_group.http_helium_platform.id
}

output "mysql_sg" {
  value = aws_security_group.mysql.id
}

output "elasticache_sg" {
  value = aws_security_group.elasticache.id
}