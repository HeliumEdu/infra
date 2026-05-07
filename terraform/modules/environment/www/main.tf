// Marketing/landing site for heliumedu.com.
// Pre-cutover (until 2026-08-01): served at landing.${env_prefix}heliumedu.com.
// Post-cutover: the legacy `www.heliumedu.com` CloudFront distribution in the cloudfront
// module should be repointed to this bucket as origin, and `landing.*` resources here
// can be removed (set is_landing_alias_enabled = false).

resource "aws_s3_bucket" "heliumedu_www_static" {
  bucket = "heliumedu.${var.environment}.www.static"
}

resource "aws_s3_bucket_public_access_block" "heliumedu_www_static_allow_public" {
  bucket = aws_s3_bucket.heliumedu_www_static.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "heliumedu_www_static_allow_http_access" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    resources = [
      "arn:aws:s3:::heliumedu.${var.environment}.www.static/**",
    ]

    actions = [
      "s3:GetObject"
    ]
  }
}

resource "aws_s3_bucket_policy" "heliumedu_www_static_allow_http_access" {
  bucket = aws_s3_bucket.heliumedu_www_static.id
  policy = data.aws_iam_policy_document.heliumedu_www_static_allow_http_access.json

  depends_on = [aws_s3_bucket_public_access_block.heliumedu_www_static_allow_public]
}

resource "aws_s3_bucket_cors_configuration" "heliumedu_www_static" {
  bucket = aws_s3_bucket.heliumedu_www_static.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_website_configuration" "heliumedu_www_static" {
  bucket = aws_s3_bucket.heliumedu_www_static.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }
}

// CloudFront distribution for landing.${env_prefix}heliumedu.com (pre-cutover only).
resource "aws_cloudfront_distribution" "landing_heliumedu_com" {
  count = var.is_landing_alias_enabled ? 1 : 0

  enabled             = true
  aliases             = ["landing.${var.environment_prefix}${var.route53_heliumedu_com_zone_name}"]
  comment             = "landing.${var.environment_prefix}${var.route53_heliumedu_com_zone_name}"
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  origin {
    origin_id   = "${aws_s3_bucket.heliumedu_www_static.bucket}-origin"
    domain_name = aws_s3_bucket_website_configuration.heliumedu_www_static.website_endpoint
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1"]
    }
  }

  default_cache_behavior {
    target_origin_id = "${aws_s3_bucket.heliumedu_www_static.bucket}-origin"
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
    acm_certificate_arn            = var.heliumedu_com_cert_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

resource "aws_route53_record" "landing_heliumedu_com" {
  count = var.is_landing_alias_enabled ? 1 : 0

  zone_id = var.route53_heliumedu_com_zone_id
  name    = "landing.${var.environment_prefix}${var.route53_heliumedu_com_zone_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.landing_heliumedu_com[0].domain_name
    zone_id                = aws_cloudfront_distribution.landing_heliumedu_com[0].hosted_zone_id
    evaluate_target_health = false
  }
}
