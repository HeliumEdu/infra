// Platform S3 credentials (for media, static files, etc.)
output "s3_access_key_id" {
  sensitive = true
  value     = aws_iam_access_key.s3_access_key.id
}

output "s3_access_key_secret" {
  sensitive = true
  value     = aws_iam_access_key.s3_access_key.secret
}

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
