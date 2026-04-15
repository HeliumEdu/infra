output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.heliumedu_frontend.domain_name
}

output "ci_frontend_app_cloudfront_domain_name" {
  value = length(aws_cloudfront_distribution.heliumedu_ci_frontend_app) > 0 ? aws_cloudfront_distribution.heliumedu_ci_frontend_app[0].domain_name : null
}
