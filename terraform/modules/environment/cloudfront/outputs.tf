output "ci_frontend_app_cloudfront_domain_name" {
  value = length(aws_cloudfront_distribution.heliumedu_ci_frontend_app) > 0 ? aws_cloudfront_distribution.heliumedu_ci_frontend_app[0].domain_name : null
}

output "muppets_response_headers_policy_id" {
  value = aws_cloudfront_response_headers_policy.muppets.id
}
