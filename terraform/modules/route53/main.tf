resource "aws_route53_zone" "heliumedu_com_zone" {
  name = "${var.environment_prefix}heliumedu.com"
}

resource "aws_route53_zone" "heliumedu_dev_zone" {
  name = "${var.environment_prefix}heliumedu.dev"
}

// Record only created once, to point non-production zones' subdomain to the primary zone

resource "aws_route53_record" "heliumedu_com_ns" {
  count = var.parent_com_zone_id != null ? 1 : 0

  zone_id = var.parent_com_zone_id
  name    = "${var.environment_prefix}heliumedu.com"
  type    = "NS"
  ttl     = "300"
  records = aws_route53_zone.heliumedu_com_zone.name_servers
}

resource "aws_route53_record" "heliumedu_dev_ns" {
  count = var.parent_dev_zone_id != null ? 1 : 0

  zone_id = var.parent_dev_zone_id
  name    = "${var.environment_prefix}heliumedu.dev"
  type    = "NS"
  ttl     = "300"
  records = aws_route53_zone.heliumedu_dev_zone.name_servers
}

// Records only created once, for production

resource "aws_route53_record" "blog_heliumedu_com_cname" {
  count = var.environment == "prod" ? 1 : 0

  zone_id = aws_route53_zone.heliumedu_com_zone.id
  name    = "blog.heliumedu.com"
  type    = "CNAME"
  ttl     = "86400"
  records = ["domains.tumblr.com"]
}

resource "aws_route53_record" "heliumedu_com_gh_txt" {
  count = var.environment == "prod" ? 1 : 0

  zone_id = aws_route53_zone.heliumedu_com_zone.id
  name    = "_gh-HeliumEdu-o.heliumedu.com"
  type    = "TXT"
  ttl     = "3600"
  records = ["b73c3b72a1"]
}

resource "aws_route53_record" "status_heliumedu_com_cname" {
  count = var.environment == "prod" ? 1 : 0

  zone_id = aws_route53_zone.heliumedu_com_zone.id
  name    = "status.heliumedu.com"
  type    = "CNAME"
  ttl     = "86400"
  records = ["statuspage.betteruptime.com"]
}
