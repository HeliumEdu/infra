resource "aws_vpc" "helium_vpc" {
  cidr_block = "172.30.0.0/16"
}

output "vpc_id" {
  value = aws_vpc.helium_vpc.id
}

resource "aws_subnet" "subnet_us_east_1a" {
  vpc_id                  = aws_vpc.helium_vpc.id
  cidr_block              = "172.30.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "subnet_us_east_1b" {
  vpc_id                  = aws_vpc.helium_vpc.id
  cidr_block              = "172.30.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

output "subnet_ids" {
  value = [aws_subnet.subnet_us_east_1a.id, aws_subnet.subnet_us_east_1b.id]
}

resource "aws_internet_gateway" "helium_gateway" {
  vpc_id = aws_vpc.helium_vpc.id
}

resource "aws_route_table" "helium_route_table" {
  vpc_id = aws_vpc.helium_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_internet_gateway.helium_gateway.id
  }
}

resource "aws_security_group" "http_s" {
  name   = "http/s (public)"
  vpc_id = aws_vpc.helium_vpc.id
}

output "http_s_sg_id" {
  value = aws_security_group.http_s.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.http_s.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_ipv4" {
  security_group_id = aws_security_group.http_s.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound_http_s" {
  security_group_id = aws_security_group.http_s.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  ip_protocol       = "tcp"
  to_port           = 65535
}

resource "aws_security_group" "http_helium_frontend" {
  name   = "http-helium-frontend"
  vpc_id = aws_vpc.helium_vpc.id
}

output "http_sg_frontend" {
  value = aws_security_group.http_helium_frontend.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_helium_frontend_ipv4" {
  security_group_id = aws_security_group.http_helium_frontend.id
  cidr_ipv4         = aws_vpc.helium_vpc.cidr_block
  from_port         = 3000
  ip_protocol       = "tcp"
  to_port           = 3000
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound_frontend" {
  security_group_id = aws_security_group.http_helium_frontend.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  ip_protocol       = "tcp"
  to_port           = 65535
}

resource "aws_security_group" "http_helium_platform" {
  name   = "http-helium-platform"
  vpc_id = aws_vpc.helium_vpc.id
}

output "http_sg_platform" {
  value = aws_security_group.http_helium_platform.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_helium_platform_ipv4" {
  security_group_id = aws_security_group.http_helium_platform.id
  cidr_ipv4         = aws_vpc.helium_vpc.cidr_block
  from_port         = 8000
  ip_protocol       = "tcp"
  to_port           = 8000
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound_platform" {
  security_group_id = aws_security_group.http_helium_platform.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  ip_protocol       = "tcp"
  to_port           = 65535
}

resource "aws_security_group" "mysql" {
  name   = "mysql"
  vpc_id = aws_vpc.helium_vpc.id
}

output "mysql_sg" {
  value = aws_security_group.mysql.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_mysql_ipv4" {
  security_group_id = aws_security_group.mysql.id
  cidr_ipv4         = aws_vpc.helium_vpc.cidr_block
  from_port         = 3306
  ip_protocol       = "tcp"
  to_port           = 3306
}

resource "aws_security_group" "elasticache" {
  name   = "elasticache"
  vpc_id = aws_vpc.helium_vpc.id
}

output "elasticache_sg" {
  value = aws_security_group.mysql.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_elasticache_ipv4" {
  security_group_id = aws_security_group.elasticache.id
  cidr_ipv4         = aws_vpc.helium_vpc.cidr_block
  from_port         = 6379
  ip_protocol       = "tcp"
  to_port           = 6379
}