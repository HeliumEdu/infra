resource "aws_cloudfront_function" "rewrites" {
  name    = "${var.environment}-rewrites"
  runtime = "cloudfront-js-2.0"
  publish = true
  code    = file("${path.module}/rewrites.js")
}

resource "aws_cloudfront_function" "rewrites_spa" {
  name    = "${var.environment}-rewrites-spa"
  runtime = "cloudfront-js-2.0"
  publish = true
  code    = file("${path.module}/rewrites-spa.js")
}

resource "aws_cloudfront_distribution" "heliumedu_frontend" {
  enabled             = true
  aliases             = ["www.${var.route53_heliumedu_com_zone_name}"]
  comment             = "www.${var.route53_heliumedu_com_zone_name}"
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  origin {
    origin_id   = "${var.s3_bucket}-origin"
    domain_name = var.s3_website_endpoint
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1"]
    }
  }

  default_cache_behavior {
    target_origin_id = "${var.s3_bucket}-origin"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    default_ttl            = 3600
    min_ttl                = 300
    max_ttl                = 86400

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.rewrites.arn
    }
  }

  custom_error_response {
    error_code         = 404
    response_code      = 404
    response_page_path = "/404.html"
  }

  custom_error_response {
    error_code         = 500
    response_code      = 500
    response_page_path = "/500.html"
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

resource "aws_route53_record" "www_heliumedu_com" {
  zone_id = var.route53_heliumedu_com_zone_id
  name    = "www.${var.route53_heliumedu_com_zone_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.heliumedu_frontend.domain_name
    zone_id                = aws_cloudfront_distribution.heliumedu_frontend.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_s3_bucket" "heliumedu_frontend_non_www" {
  bucket = "heliumedu.${var.environment}.frontend.non-www-redirect"
}

resource "aws_s3_bucket_website_configuration" "heliumedu_frontend_non_www_config" {
  bucket = aws_s3_bucket.heliumedu_frontend_non_www.bucket

  redirect_all_requests_to {
    host_name = "www.${var.route53_heliumedu_com_zone_name}"
    protocol  = "https"
  }
}

resource "aws_cloudfront_distribution" "heliumedu_frontend_non_www" {
  enabled     = true
  aliases     = [var.route53_heliumedu_com_zone_name]
  comment     = var.route53_heliumedu_com_zone_name
  price_class = "PriceClass_100"

  origin {
    domain_name = aws_s3_bucket_website_configuration.heliumedu_frontend_non_www_config.website_endpoint
    origin_id   = "${aws_s3_bucket.heliumedu_frontend_non_www.bucket}-origin"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id = "${aws_s3_bucket.heliumedu_frontend_non_www.bucket}-origin"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    default_ttl            = 0
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

resource "aws_route53_record" "heliumedu_com" {
  zone_id = var.route53_heliumedu_com_zone_id
  name    = var.route53_heliumedu_com_zone_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.heliumedu_frontend_non_www.domain_name
    zone_id                = aws_cloudfront_distribution.heliumedu_frontend_non_www.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_s3_bucket" "support_redirect_bucket" {
  bucket = "support.${var.environment_prefix}heliumedu.com-redirect"
}

resource "aws_s3_bucket_website_configuration" "support_redirect_bucket" {
  bucket = aws_s3_bucket.support_redirect_bucket.bucket

  redirect_all_requests_to {
    host_name = "heliumedu.freshdesk.com"
    protocol  = "https"
  }
}

data "aws_iam_policy_document" "heliumedu_support_redirect_allow_http_access" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    resources = [
      "arn:aws:s3:::support.${var.environment_prefix}heliumedu.com-redirect/**",
    ]

    actions = [
      "s3:GetObject"
    ]
  }
}

resource "aws_s3_bucket_public_access_block" "heliumedu_support_redirect_allow_public" {
  bucket = aws_s3_bucket.support_redirect_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "heliumedu_support_redirect_allow_http_access" {
  bucket = aws_s3_bucket.support_redirect_bucket.id
  policy = data.aws_iam_policy_document.heliumedu_support_redirect_allow_http_access.json

  depends_on = [aws_s3_bucket_public_access_block.heliumedu_support_redirect_allow_public]
}

resource "aws_cloudfront_distribution" "support_heliumedu_com" {
  enabled     = true
  aliases     = ["support.${var.route53_heliumedu_com_zone_name}"]
  comment     = "support.${var.route53_heliumedu_com_zone_name}"
  price_class = "PriceClass_100"

  origin {
    domain_name = aws_s3_bucket_website_configuration.support_redirect_bucket.website_endpoint
    origin_id   = "${aws_s3_bucket.support_redirect_bucket.bucket}-origin"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id = "${aws_s3_bucket.support_redirect_bucket.bucket}-origin"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    default_ttl            = 0
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

resource "aws_route53_record" "support_heliumedu_com" {
  zone_id = var.route53_heliumedu_com_zone_id
  name    = "support.${var.route53_heliumedu_com_zone_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.support_heliumedu_com.domain_name
    zone_id                = aws_cloudfront_distribution.support_heliumedu_com.hosted_zone_id
    evaluate_target_health = false
  }
}

// Flutter app frontend (app.heliumedu.com)

resource "aws_cloudfront_distribution" "app_heliumedu_com" {
  enabled             = true
  aliases             = ["app.${var.route53_heliumedu_com_zone_name}"]
  comment             = "app.${var.route53_heliumedu_com_zone_name}"
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  origin {
    origin_id   = "${var.s3_frontend_app_bucket}-origin"
    domain_name = var.s3_frontend_app_website_endpoint
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1"]
    }
  }

  default_cache_behavior {
    target_origin_id = "${var.s3_frontend_app_bucket}-origin"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    default_ttl            = 3600
    min_ttl                = 300
    max_ttl                = 86400

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.rewrites_spa.arn
    }
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
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

resource "aws_route53_record" "app_heliumedu_com" {
  zone_id = var.route53_heliumedu_com_zone_id
  name    = "app.${var.route53_heliumedu_com_zone_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.app_heliumedu_com.domain_name
    zone_id                = aws_cloudfront_distribution.app_heliumedu_com.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_s3_bucket" "heliumstudy_frontend_non_www" {
  bucket = "heliumstudy.${var.environment}.frontend.non-www-redirect"
}

resource "aws_s3_bucket_website_configuration" "heliumstudy_frontend_non_www_config" {
  bucket = aws_s3_bucket.heliumstudy_frontend_non_www.bucket

  redirect_all_requests_to {
    host_name = "www.${var.route53_heliumstudy_com_zone_name}"
    protocol  = "https"
  }
}

resource "aws_cloudfront_distribution" "heliumstudy_frontend_non_www" {
  enabled     = true
  aliases     = [var.route53_heliumstudy_com_zone_name]
  comment     = var.route53_heliumstudy_com_zone_name
  price_class = "PriceClass_100"

  origin {
    domain_name = aws_s3_bucket_website_configuration.heliumstudy_frontend_non_www_config.website_endpoint
    origin_id   = "${aws_s3_bucket.heliumstudy_frontend_non_www.bucket}-origin"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id = "${aws_s3_bucket.heliumstudy_frontend_non_www.bucket}-origin"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    default_ttl            = 0
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = var.heliumstudy_com_cert_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

resource "aws_route53_record" "heliumstudy_com" {
  zone_id = var.route53_heliumstudy_com_zone_id
  name    = var.route53_heliumstudy_com_zone_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.heliumstudy_frontend_non_www.domain_name
    zone_id                = aws_cloudfront_distribution.heliumstudy_frontend_non_www.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_s3_bucket" "heliumstudy_com_redirect_bucket" {
  bucket = "${var.environment_prefix}heliumstudy.com-redirect"
}

resource "aws_s3_bucket_website_configuration" "heliumstudy_com_redirect_bucket" {
  bucket = aws_s3_bucket.heliumstudy_com_redirect_bucket.bucket

  redirect_all_requests_to {
    host_name = "www.${var.environment_prefix}heliumedu.com"
    protocol  = "https"
  }
}

data "aws_iam_policy_document" "heliumstudy_com_redirect_allow_http_access" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    resources = [
      "arn:aws:s3:::${var.environment_prefix}heliumstudy.com-redirect/**",
    ]

    actions = [
      "s3:GetObject"
    ]
  }
}

resource "aws_s3_bucket_public_access_block" "heliumstudy_com_redirect_allow_public" {
  bucket = aws_s3_bucket.heliumstudy_com_redirect_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "heliumstudy_com_redirect_allow_http_access" {
  bucket = aws_s3_bucket.heliumstudy_com_redirect_bucket.id
  policy = data.aws_iam_policy_document.heliumstudy_com_redirect_allow_http_access.json

  depends_on = [aws_s3_bucket_public_access_block.heliumstudy_com_redirect_allow_public]
}

resource "aws_cloudfront_distribution" "heliumstudy_com" {
  enabled     = true
  aliases     = ["www.${var.route53_heliumstudy_com_zone_name}"]
  comment     = "www.${var.route53_heliumstudy_com_zone_name}"
  price_class = "PriceClass_100"

  origin {
    domain_name = aws_s3_bucket_website_configuration.heliumstudy_com_redirect_bucket.website_endpoint
    origin_id   = "${aws_s3_bucket.heliumstudy_com_redirect_bucket.bucket}-origin"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id = "${aws_s3_bucket.heliumstudy_com_redirect_bucket.bucket}-origin"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    default_ttl            = 0
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = var.heliumstudy_com_cert_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

resource "aws_route53_record" "www_heliumstudy_com" {
  zone_id = var.route53_heliumstudy_com_zone_id
  name    = "www.${var.route53_heliumstudy_com_zone_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.heliumstudy_com.domain_name
    zone_id                = aws_cloudfront_distribution.heliumstudy_com.hosted_zone_id
    evaluate_target_health = false
  }
}
