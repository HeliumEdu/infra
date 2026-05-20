module "datadog" {
  source = "../../modules/global/datadog"

  aws_account_id = var.AWS_ACCOUNT_ID
}

data "tfe_organization_membership" "notification_recipient" {
  organization = "HeliumEdu"
  email        = "support@heliumedu.com"
}

module "hcp_notifications" {
  source = "../../modules/global/hcp"

  organization      = "HeliumEdu"
  recipient_user_id = data.tfe_organization_membership.notification_recipient.user_id

  workspaces = {
    "prod"      = { enabled = true }
    "dev"       = { enabled = var.dev_env_enabled }
    "dev-local" = { enabled = true }
  }
}

data "aws_route53_zone" "heliumedu_com" {
  name = "heliumedu.com"
}

resource "aws_s3_bucket" "www" {
  bucket = "heliumedu.www.static"
}

resource "aws_s3_bucket_public_access_block" "www" {
  bucket = aws_s3_bucket.www.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "www_allow_http_access" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    resources = ["${aws_s3_bucket.www.arn}/*"]
    actions   = ["s3:GetObject"]
  }
}

resource "aws_s3_bucket_policy" "www" {
  bucket = aws_s3_bucket.www.id
  policy = data.aws_iam_policy_document.www_allow_http_access.json

  depends_on = [aws_s3_bucket_public_access_block.www]
}

resource "aws_s3_bucket_cors_configuration" "www" {
  bucket = aws_s3_bucket.www.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_website_configuration" "www" {
  bucket = aws_s3_bucket.www.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }
}

resource "aws_acm_certificate" "marketing" {
  domain_name               = "www.heliumedu.com"
  subject_alternative_names = ["landing.heliumedu.com"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "marketing_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.marketing.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id         = data.aws_route53_zone.heliumedu_com.zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 60
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "marketing" {
  certificate_arn         = aws_acm_certificate.marketing.arn
  validation_record_fqdns = [for record in aws_route53_record.marketing_cert_validation : record.fqdn]
}

resource "aws_cloudfront_distribution" "marketing" {
  enabled             = true
  aliases             = ["www.heliumedu.com"]
  comment             = "www.heliumedu.com"
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  origin {
    origin_id   = "${aws_s3_bucket.www.bucket}-origin"
    domain_name = aws_s3_bucket_website_configuration.www.website_endpoint
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1"]
    }
  }

  default_cache_behavior {
    target_origin_id = "${aws_s3_bucket.www.bucket}-origin"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    default_ttl            = 3600
    min_ttl                = 0
    max_ttl                = 86400
  }

  custom_error_response {
    error_code         = 404
    response_code      = 404
    response_page_path = "/404.html"
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = aws_acm_certificate_validation.marketing.certificate_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

resource "aws_route53_record" "www_heliumedu_com" {
  zone_id = data.aws_route53_zone.heliumedu_com.zone_id
  name    = "www.heliumedu.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.marketing.domain_name
    zone_id                = aws_cloudfront_distribution.marketing.hosted_zone_id
    evaluate_target_health = false
  }
}

// Redirect-only host: landing.heliumedu.com -> https://www.heliumedu.com{path}

resource "aws_s3_bucket" "landing_redirect" {
  bucket = "landing.heliumedu.com-redirect"
}

resource "aws_s3_bucket_public_access_block" "landing_redirect" {
  bucket = aws_s3_bucket.landing_redirect.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "landing_redirect_allow_http_access" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    resources = ["${aws_s3_bucket.landing_redirect.arn}/*"]
    actions   = ["s3:GetObject"]
  }
}

resource "aws_s3_bucket_policy" "landing_redirect" {
  bucket = aws_s3_bucket.landing_redirect.id
  policy = data.aws_iam_policy_document.landing_redirect_allow_http_access.json

  depends_on = [aws_s3_bucket_public_access_block.landing_redirect]
}

resource "aws_s3_bucket_website_configuration" "landing_redirect" {
  bucket = aws_s3_bucket.landing_redirect.bucket

  redirect_all_requests_to {
    host_name = "www.heliumedu.com"
    protocol  = "https"
  }
}

resource "aws_cloudfront_distribution" "landing_redirect" {
  enabled     = true
  aliases     = ["landing.heliumedu.com"]
  comment     = "landing.heliumedu.com (redirect to www.heliumedu.com)"
  price_class = "PriceClass_100"

  origin {
    domain_name = aws_s3_bucket_website_configuration.landing_redirect.website_endpoint
    origin_id   = "${aws_s3_bucket.landing_redirect.bucket}-origin"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id = "${aws_s3_bucket.landing_redirect.bucket}-origin"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    default_ttl            = 0
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = aws_acm_certificate_validation.marketing.certificate_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  // Wait for the marketing distribution's alias swap to release landing.heliumedu.com
  // before this distribution attempts to claim it.
  depends_on = [aws_cloudfront_distribution.marketing]
}

resource "aws_route53_record" "landing" {
  zone_id = data.aws_route53_zone.heliumedu_com.zone_id
  name    = "landing.heliumedu.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.landing_redirect.domain_name
    zone_id                = aws_cloudfront_distribution.landing_redirect.hosted_zone_id
    evaluate_target_health = false
  }
}

// Migration shims: rename existing resources rather than destroy/recreate to avoid
// disruption during apply. After this PR settles, these moved blocks can be removed.

moved {
  from = aws_acm_certificate.landing
  to   = aws_acm_certificate.marketing
}

moved {
  from = aws_route53_record.landing_cert_validation
  to   = aws_route53_record.marketing_cert_validation
}

moved {
  from = aws_acm_certificate_validation.landing
  to   = aws_acm_certificate_validation.marketing
}

moved {
  from = aws_cloudfront_distribution.landing
  to   = aws_cloudfront_distribution.marketing
}
