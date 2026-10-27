resource "aws_vpc" "helium_vpc" {
  cidr_block                       = "172.30.0.0/16"
  assign_generated_ipv6_cidr_block = true
}

resource "aws_subnet" "subnets" {
  for_each                = var.region_azs
  vpc_id                  = aws_vpc.helium_vpc.id
  cidr_block              = "172.30.${each.value["index"]}.0/24"
  ipv6_cidr_block         = cidrsubnet(aws_vpc.helium_vpc.ipv6_cidr_block, 8, each.value["index"])
  availability_zone       = "${var.aws_region}${each.value["suffix"]}"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "helium_gateway" {
  vpc_id = aws_vpc.helium_vpc.id
}

resource "aws_route_table" "helium_route_table" {
  vpc_id = aws_vpc.helium_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.helium_gateway.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.helium_gateway.id
  }
}

resource "aws_route_table_association" "route_table_association" {
  for_each       = aws_subnet.subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.helium_route_table.id
}

# CloudFront VPC origins can't use use1-az3 (us-east-1e in this account)
resource "aws_subnet" "private_subnets" {
  for_each                = var.region_azs
  vpc_id                  = aws_vpc.helium_vpc.id
  cidr_block              = "172.30.${each.value["index"] + 10}.0/24"
  availability_zone       = "${var.aws_region}${each.value["suffix"]}"
  map_public_ip_on_launch = false
}

resource "aws_route_table" "helium_private_route_table" {
  vpc_id = aws_vpc.helium_vpc.id
}

resource "aws_route_table_association" "private_route_table_association" {
  for_each       = aws_subnet.private_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.helium_private_route_table.id
}

data "aws_ec2_managed_prefix_list" "cloudfront_origin_facing" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

resource "aws_security_group" "https_cloudfront" {
  name   = "helium-https-cloudfront_${var.environment}"
  vpc_id = aws_vpc.helium_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_cloudfront" {
  security_group_id = aws_security_group.https_cloudfront.id
  prefix_list_id    = data.aws_ec2_managed_prefix_list.cloudfront_origin_facing.id
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound_https_cloudfront" {
  security_group_id = aws_security_group.https_cloudfront.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  ip_protocol       = "tcp"
  to_port           = 65535
}

resource "aws_security_group" "http_helium_platform" {
  name   = "helium-http-platform_${var.environment}"
  vpc_id = aws_vpc.helium_vpc.id
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
  name   = "helium-mysql_${var.environment}"
  vpc_id = aws_vpc.helium_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_mysql_ipv4" {
  security_group_id = aws_security_group.mysql.id
  cidr_ipv4         = aws_vpc.helium_vpc.cidr_block
  from_port         = 3306
  ip_protocol       = "tcp"
  to_port           = 3306
}

resource "aws_security_group" "elasticache" {
  name   = "helium-elasticache_${var.environment}"
  vpc_id = aws_vpc.helium_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_elasticache_ipv4" {
  security_group_id = aws_security_group.elasticache.id
  cidr_ipv4         = aws_vpc.helium_vpc.cidr_block
  from_port         = 6379
  ip_protocol       = "tcp"
  to_port           = 6379
}