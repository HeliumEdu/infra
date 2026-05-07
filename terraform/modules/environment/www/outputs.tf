output "heliumedu_s3_www_bucket_name" {
  value = aws_s3_bucket.heliumedu_www_static.bucket
}

output "heliumedu_s3_www_website_endpoint" {
  value = aws_s3_bucket_website_configuration.heliumedu_www_static.website_endpoint
}

output "landing_cloudfront_domain_name" {
  value       = var.is_landing_alias_enabled ? aws_cloudfront_distribution.landing_heliumedu_com[0].domain_name : null
  description = "CloudFront domain for the pre-cutover landing.* distribution."
}
