resource "aws_route53_zone" "heliumedu_com_zone" {
  name = "${var.environment_prefix}heliumedu.com"
}

resource "aws_route53_record" "www_heliumedu_com_cname" {
  zone_id = aws_route53_zone.heliumedu_com_zone.id
  name    = "www.${var.environment_prefix}heliumedu.com"
  type    = "CNAME"
  ttl     = "86400"
  records = ["${var.environment_prefix}heliumedu.com"]
}

resource "aws_route53_record" "blog_heliumedu_com_cname" {
  zone_id = aws_route53_zone.heliumedu_com_zone.id
  name    = "blog.${var.environment_prefix}heliumedu.com"
  type    = "CNAME"
  ttl     = "86400"
  records = ["domains.tumblr.com"]
}

resource "aws_route53_zone" "heliumedu_dev_zone" {
  name = "${var.environment_prefix}heliumedu.dev"
}

// Records only created once, for production

resource "aws_route53_record" "heliumedu_com_gh_txt" {
  count = var.environment == "prod" ? 1 : 0

  zone_id = aws_route53_zone.heliumedu_com_zone.id
  name    = "_gh-HeliumEdu-o.heliumedu.com"
  type    = "TXT"
  ttl     = "3600"
  records = ["b73c3b72a1"]
}
