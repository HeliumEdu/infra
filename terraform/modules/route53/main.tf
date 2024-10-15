resource "aws_route53_zone" "heliumedu_com_zone" {
  name = "${var.environment_prefix}heliumedu.com"
}

resource "aws_route53_record" "www_heliumedu_com_cname" {
  zone_id = aws_route53_zone.heliumedu_com_zone.id
  name    = "www.${var.environment_prefix}heliumedu.com"
  type    = "CNAME"
  ttl     = "600"
  records = ["${var.environment_prefix}heliumedu.com"]
}

resource "aws_route53_zone" "heliumedu_dev_zone" {
  name = "${var.environment_prefix}heliumedu.dev"
}