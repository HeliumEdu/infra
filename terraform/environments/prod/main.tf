data "aws_caller_identity" "current" {}

locals {
  aws_account_id = data.aws_caller_identity.current.account_id
}

module "route53" {
  source = "../../modules/environment/route53"

  environment        = var.environment
  environment_prefix = var.environment_prefix
}

module "certificatemanager" {
  source = "../../modules/environment/certificatemanager"

  route53_heliumedu_com_zone_id     = module.route53.heliumedu_com_zone_id
  route53_heliumedu_com_zone_name   = module.route53.heliumedu_com_zone_name
  route53_heliumedu_dev_zone_id     = module.route53.heliumedu_dev_zone_id
  route53_heliumedu_dev_zone_name   = module.route53.heliumedu_dev_zone_name
  route53_heliumstudy_com_zone_id   = module.route53.heliumstudy_com_zone_id
  route53_heliumstudy_com_zone_name = module.route53.heliumstudy_com_zone_name
  route53_heliumstudy_dev_zone_id   = module.route53.heliumstudy_dev_zone_id
  route53_heliumstudy_dev_zone_name = module.route53.heliumstudy_dev_zone_name
}

module "vpc" {
  source = "../../modules/environment/vpc"

  environment = var.environment
  aws_region  = var.aws_region
  region_azs  = var.region_azs
}

module "alb" {
  source = "../../modules/environment/alb"

  environment                     = var.environment
  route53_heliumedu_com_zone_id   = module.route53.heliumedu_com_zone_id
  route53_heliumedu_com_zone_name = module.route53.heliumedu_com_zone_name
  security_group                  = module.vpc.http_s_sg_id
  subnet_ids                      = module.vpc.subnet_ids
  helium_vpc_id                   = module.vpc.vpc_id
  heliumedu_com_cert_arn          = module.certificatemanager.heliumedu_com_cert_arn
  alb_access_logs_bucket          = module.s3.heliumedu_s3_alb_logs_bucket_name
  request_timeout_seconds         = var.request_timeout_seconds
}

module "rds" {
  source = "../../modules/environment/rds"

  environment   = var.environment
  subnet_ids    = module.vpc.subnet_ids
  mysql_sg      = module.vpc.mysql_sg
  multi_az      = var.db_multi_az
  instance_size = var.db_instance_size
}

module "ecr" {
  source = "../../modules/environment/ecr"
}

module "ecs" {
  source = "../../modules/environment/ecs"

  helium_version                   = var.helium_version
  minimum_supported_version        = var.minimum_supported_version
  default_arch                     = var.default_arch
  platform_host_count              = var.platform_host_count
  platform_worker_count            = var.platform_worker_count
  platform_resource_repository_uri = module.ecr.platform_resource_repository_uri
  platform_api_repository_uri      = module.ecr.platform_api_repository_uri
  platform_worker_repository_uri   = module.ecr.platform_worker_repository_uri
  environment                      = var.environment
  aws_account_id                   = local.aws_account_id
  aws_region                       = var.aws_region
  http_platform                    = module.vpc.http_sg_platform
  platform_target_group            = module.alb.platform_target_group
  subnet_ids                       = module.vpc.subnet_ids
  request_timeout_seconds          = var.request_timeout_seconds
}

module "elasticache" {
  source = "../../modules/environment/elasticache"

  environment     = var.environment
  subnet_ids      = module.vpc.subnet_ids
  elasticache_sg  = module.vpc.elasticache_sg
  num_cache_nodes = var.num_cache_nodes
  instance_size   = var.cache_instance_size
}

module "email" {
  source = "../../modules/environment/email"

  environment                     = var.environment
  route53_heliumedu_com_zone_id   = module.route53.heliumedu_com_zone_id
  route53_heliumedu_com_zone_name = module.route53.heliumedu_com_zone_name
}

module "s3" {
  source = "../../modules/environment/s3"

  aws_account_id = local.aws_account_id
  environment    = var.environment
}

module "cloudfront" {
  source = "../../modules/environment/cloudfront"

  environment                         = var.environment
  environment_prefix                  = var.environment_prefix
  s3_frontend_app_bucket              = module.s3.heliumedu_s3_frontend_app_bucket_name
  s3_frontend_app_website_endpoint    = module.s3.heliumedu_s3_frontend_app_website_endpoint
  s3_ci_frontend_app_website_endpoint = module.s3.heliumedu_ci_s3_frontend_app_website_endpoint
  heliumedu_com_cert_arn              = module.certificatemanager.heliumedu_com_cert_arn
  route53_heliumedu_com_zone_id       = module.route53.heliumedu_com_zone_id
  route53_heliumedu_com_zone_name     = module.route53.heliumedu_com_zone_name
  heliumstudy_com_cert_arn            = module.certificatemanager.heliumstudy_com_cert_arn
  route53_heliumstudy_com_zone_id     = module.route53.heliumstudy_com_zone_id
  route53_heliumstudy_com_zone_name   = module.route53.heliumstudy_com_zone_name
}

module "ses" {
  source = "../../modules/environment/ses"

  environment                     = var.environment
  aws_region                      = var.aws_region
  route53_heliumedu_com_zone_id   = module.route53.heliumedu_com_zone_id
  route53_heliumedu_com_zone_name = module.route53.heliumedu_com_zone_name
  route53_heliumedu_dev_zone_id   = module.route53.heliumedu_dev_zone_id
  route53_heliumedu_dev_zone_name = module.route53.heliumedu_dev_zone_name
}

module "secretsmanager" {
  source = "../../modules/environment/secretsmanager"

  environment                   = var.environment
  aws_account_id                = local.aws_account_id
  aws_region                    = var.aws_region
  task_execution_role_arn       = module.ecs.task_execution_role_arn
  datadog_api_key               = var.DD_API_KEY
  redis_host                    = module.elasticache.elasticache_host
  redis_auth_token              = module.elasticache.elasticache_auth_token
  db_host                       = module.rds.db_host
  db_user                       = module.rds.db_username
  db_password                   = module.rds.db_password
  sentry_dsn                    = var.SENTRY_DSN
  jsm_api_token                 = var.JSM_API_TOKEN
  s3_user_access_key_id         = module.s3.s3_access_key_id
  s3_user_secret_access_key     = module.s3.s3_access_key_secret
  smtp_email_user               = module.ses.smtp_username
  smtp_email_password           = module.ses.smtp_password
  ci_app_host                   = module.cloudfront.ci_frontend_app_cloudfront_domain_name
  firebase_project_id           = var.FIREBASE_PROJECT_ID
  firebase_private_key_id       = var.FIREBASE_PRIVATE_KEY_ID
  firebase_private_key          = var.FIREBASE_PRIVATE_KEY
  firebase_client_email         = var.FIREBASE_CLIENT_EMAIL
  firebase_client_id            = var.FIREBASE_CLIENT_ID
  firebase_client_x509_cert_url = var.FIREBASE_CLIENT_X509_CERT_URL
  ga4_measurement_id            = var.GA4_MEASUREMENT_ID
  ga4_api_secret                = var.GA4_API_SECRET
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

  zone_id         = module.route53.heliumedu_com_zone_id
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
  zone_id = module.route53.heliumedu_com_zone_id
  name    = "www.heliumedu.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.marketing.domain_name
    zone_id                = aws_cloudfront_distribution.marketing.hosted_zone_id
    evaluate_target_health = false
  }
}

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
}

resource "aws_route53_record" "landing" {
  zone_id = module.route53.heliumedu_com_zone_id
  name    = "landing.heliumedu.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.landing_redirect.domain_name
    zone_id                = aws_cloudfront_distribution.landing_redirect.hosted_zone_id
    evaluate_target_health = false
  }
}

import {
  to = aws_s3_bucket.www
  id = "heliumedu.www.static"
}

import {
  to = aws_s3_bucket_public_access_block.www
  id = "heliumedu.www.static"
}

import {
  to = aws_s3_bucket_policy.www
  id = "heliumedu.www.static"
}

import {
  to = aws_s3_bucket_cors_configuration.www
  id = "heliumedu.www.static"
}

import {
  to = aws_s3_bucket_website_configuration.www
  id = "heliumedu.www.static"
}

import {
  to = aws_s3_bucket.landing_redirect
  id = "landing.heliumedu.com-redirect"
}

import {
  to = aws_s3_bucket_public_access_block.landing_redirect
  id = "landing.heliumedu.com-redirect"
}

import {
  to = aws_s3_bucket_policy.landing_redirect
  id = "landing.heliumedu.com-redirect"
}

import {
  to = aws_s3_bucket_website_configuration.landing_redirect
  id = "landing.heliumedu.com-redirect"
}

import {
  to = aws_acm_certificate.marketing
  id = "arn:aws:acm:us-east-1:562129510549:certificate/84931a07-1c25-42c2-8dc8-d27bb5d055ce"
}

import {
  to = aws_cloudfront_distribution.marketing
  id = "EDNGG671XEBWW"
}

import {
  to = aws_cloudfront_distribution.landing_redirect
  id = "EGQPK4YBMWVCC"
}

import {
  to = aws_route53_record.www_heliumedu_com
  id = "Z100615238TR7W7P1S38U_www.heliumedu.com_A"
}

import {
  to = aws_route53_record.landing
  id = "Z100615238TR7W7P1S38U_landing.heliumedu.com_A"
}

import {
  to = aws_route53_record.marketing_cert_validation["www.heliumedu.com"]
  id = "Z100615238TR7W7P1S38U__81acbfe41d489cba8585b0574dd32cab.www.heliumedu.com_CNAME"
}

import {
  to = aws_route53_record.marketing_cert_validation["landing.heliumedu.com"]
  id = "Z100615238TR7W7P1S38U__53ce36f09d53a6d5ac58f20c7dfd0ca4.landing.heliumedu.com._CNAME"
}
