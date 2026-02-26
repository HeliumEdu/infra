output "heliumedu_s3_frontend_bucket_name" {
  value = aws_s3_bucket.heliumedu_frontend_static.bucket
}

output "heliumedu_s3_website_endpoint" {
  value = aws_s3_bucket_website_configuration.heliumedu_frontend.website_endpoint
}

output "heliumedu_s3_frontend_app_bucket_name" {
  value = aws_s3_bucket.heliumedu_frontend_app_static.bucket
}

output "heliumedu_s3_frontend_app_website_endpoint" {
  value = aws_s3_bucket_website_configuration.heliumedu_frontend_app.website_endpoint
}

// Integration bucket outputs (only available in prod)
output "integration_s3_bucket_name" {
  value = var.environment == "prod" ? aws_s3_bucket.integration[0].bucket : null
}

output "integration_s3_access_key_id" {
  description = "Access key ID for the integration S3 user (for GitHub org secrets as AWS_INTEGRATION_S3_ACCESS_KEY_ID)"
  sensitive   = true
  value       = var.environment == "prod" ? aws_iam_access_key.integration_s3_access_key[0].id : null
}

output "integration_s3_secret_access_key" {
  description = "Secret access key for the integration S3 user (for GitHub org secrets as AWS_INTEGRATION_S3_SECRET_ACCESS_KEY)"
  sensitive   = true
  value       = var.environment == "prod" ? aws_iam_access_key.integration_s3_access_key[0].secret : null
}
