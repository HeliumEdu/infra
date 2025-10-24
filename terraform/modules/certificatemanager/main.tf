resource "aws_acm_certificate" "heliumedu_com" {
  domain_name = "${var.environment_prefix}heliumedu.com"
  subject_alternative_names = ["www.${var.environment_prefix}heliumedu.com",
    "api.${var.environment_prefix}heliumedu.com",
    "app.${var.environment_prefix}heliumedu.com",
    "support.${var.environment_prefix}heliumedu.com",
  ]
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "heliumedu_com" {
  for_each = {
    for dvo in aws_acm_certificate.heliumedu_com.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = "3600"
  type            = each.value.type
  zone_id         = var.route53_heliumedu_com_zone_id
}

resource "aws_acm_certificate_validation" "com_cert_validation" {
  certificate_arn         = aws_acm_certificate.heliumedu_com.arn
  validation_record_fqdns = [for record in aws_route53_record.heliumedu_com : record.fqdn]

  timeouts {
    create = "15m"
  }
}

resource "aws_acm_certificate" "heliumedu_dev" {
  domain_name       = "${var.environment_prefix}heliumedu.dev"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "heliumedu_dev" {
  for_each = {
    for dvo in aws_acm_certificate.heliumedu_dev.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = "3600"
  type            = each.value.type
  zone_id         = var.route53_heliumedu_dev_zone_id
}

resource "aws_acm_certificate_validation" "dev_cert_validation" {
  certificate_arn         = aws_acm_certificate.heliumedu_dev.arn
  validation_record_fqdns = [for record in aws_route53_record.heliumedu_dev : record.fqdn]

  timeouts {
    create = "15m"
  }
}
