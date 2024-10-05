resource "aws_route53_zone" "heliumedu_com_zone" {
  name = "${var.environment_prefix}heliumedu.com"
}

output "heliumedu_com_zone_id" {
  value = aws_route53_zone.heliumedu_com_zone.id
}

resource "aws_route53_zone" "heliumedu_dev_zone" {
  name = "${var.environment_prefix}heliumedu.dev"
}

output "heliumedu_dev_zone_id" {
  value = aws_route53_zone.heliumedu_com_zone.id
}