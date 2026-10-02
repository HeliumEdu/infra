resource "aws_cloudfront_distribution" "heliumedu_ci_frontend_app" {
  count = var.environment == "prod" ? 1 : 0

  enabled             = true
  comment             = "heliumedu-ci-frontend-app"
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  tags = {
    Environment = "ci"
  }

  origin {
    origin_id   = "heliumedu.ci.frontend-app.static-origin"
    domain_name = var.s3_ci_frontend_app_website_endpoint
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1"]
    }
  }

  default_cache_behavior {
    target_origin_id = "heliumedu.ci.frontend-app.static-origin"
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
    min_ttl                = 0
    max_ttl                = 0

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
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
