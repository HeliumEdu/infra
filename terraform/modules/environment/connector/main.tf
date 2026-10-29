locals {
  connector_enabled = var.connector_version != null
  function_name     = "helium-${var.environment}-connector"
  mcp_host          = "mcp.${var.route53_heliumedu_com_zone_name}"
}

data "aws_iam_policy_document" "connector_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "connector" {
  name = "${local.function_name}-role"

  assume_role_policy = data.aws_iam_policy_document.connector_assume_role_policy.json
}

resource "aws_cloudwatch_log_group" "connector" {
  name              = "/aws/lambda/${local.function_name}"
  retention_in_days = 30
}

data "aws_iam_policy_document" "connector_logs_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["${aws_cloudwatch_log_group.connector.arn}:*"]
  }
}

resource "aws_iam_role_policy" "connector_logs_policy" {
  name   = "${local.function_name}-logs-policy"
  role   = aws_iam_role.connector.id
  policy = data.aws_iam_policy_document.connector_logs_policy_document.json
}

# CloudFront sends this on every request, and the connector refuses requests without it, so the public function URL
# can't be used around CloudFront (origin access control can't sign POST bodies for a function URL)
resource "random_password" "connector_origin_secret" {
  length  = 48
  special = false
}

resource "aws_lambda_function" "connector" {
  count = local.connector_enabled ? 1 : 0

  function_name = local.function_name
  role          = aws_iam_role.connector.arn
  runtime       = "python3.13"
  architectures = ["arm64"]
  handler       = "helium_connector.lambda_handler.handler"
  s3_bucket     = "heliumedu"
  s3_key        = "helium/connector/connector-${var.connector_version}.zip"
  memory_size   = 512
  timeout       = var.request_timeout_seconds

  environment {
    variables = {
      HELIUM_API_URL       = "https://api.${var.route53_heliumedu_com_zone_name}"
      HELIUM_APP_URL       = "https://app.${var.route53_heliumedu_com_zone_name}"
      HELIUM_CONNECTOR_URL = "https://${local.mcp_host}"
      HELIUM_ENVIRONMENT   = var.environment
      HELIUM_ORIGIN_SECRET = random_password.connector_origin_secret.result
    }
  }

  depends_on = [aws_cloudwatch_log_group.connector, aws_iam_role_policy.connector_logs_policy]
}

resource "aws_lambda_function_url" "connector" {
  count = local.connector_enabled ? 1 : 0

  function_name      = aws_lambda_function.connector[0].function_name
  authorization_type = "NONE"
}

resource "aws_lambda_permission" "connector_url" {
  count = local.connector_enabled ? 1 : 0

  statement_id           = "FunctionURLAllowPublicAccess"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = aws_lambda_function.connector[0].function_name
  principal              = "*"
  function_url_auth_type = "NONE"
}

resource "aws_lambda_permission" "connector_invoke" {
  count = local.connector_enabled ? 1 : 0

  statement_id             = "FunctionURLInvokeAllowPublicAccess"
  action                   = "lambda:InvokeFunction"
  function_name            = aws_lambda_function.connector[0].function_name
  principal                = "*"
  invoked_via_function_url = true
}

data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "all_viewer_except_host_header" {
  name = "Managed-AllViewerExceptHostHeader"
}

resource "aws_cloudfront_function" "restore_www_authenticate" {
  count = local.connector_enabled ? 1 : 0

  name    = "${var.environment}-restore-www-authenticate"
  runtime = "cloudfront-js-2.0"
  publish = true
  code    = file("${path.module}/restore-www-authenticate.js")
}

resource "aws_cloudfront_distribution" "mcp_heliumedu_com" {
  count = local.connector_enabled ? 1 : 0

  enabled         = true
  aliases         = [local.mcp_host]
  comment         = local.mcp_host
  price_class     = "PriceClass_100"
  http_version    = "http2and3"
  is_ipv6_enabled = true

  tags = {
    Role = "connector"
  }

  logging_config {
    bucket          = var.cloudfront_logs_bucket_domain_name
    prefix          = "mcp/"
    include_cookies = false
  }

  origin {
    origin_id   = "${local.function_name}-origin"
    domain_name = trimsuffix(trimprefix(aws_lambda_function_url.connector[0].function_url, "https://"), "/")

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_read_timeout      = var.request_timeout_seconds
      origin_keepalive_timeout = 30
    }

    custom_header {
      name  = "X-Origin-Secret"
      value = random_password.connector_origin_secret.result
    }
  }

  default_cache_behavior {
    target_origin_id           = "${local.function_name}-origin"
    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id   = data.aws_cloudfront_origin_request_policy.all_viewer_except_host_header.id
    response_headers_policy_id = var.muppets_response_headers_policy_id
    allowed_methods            = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods             = ["GET", "HEAD"]
    viewer_protocol_policy     = "redirect-to-https"

    function_association {
      event_type   = "viewer-response"
      function_arn = aws_cloudfront_function.restore_www_authenticate[0].arn
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = var.mcp_heliumedu_com_cert_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

resource "aws_route53_record" "mcp_heliumedu_com" {
  count = local.connector_enabled ? 1 : 0

  zone_id = var.route53_heliumedu_com_zone_id
  name    = local.mcp_host
  type    = "CNAME"
  ttl     = 60
  records = [aws_cloudfront_distribution.mcp_heliumedu_com[0].domain_name]
}
