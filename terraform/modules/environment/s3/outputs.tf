output "heliumedu_s3_ci_bucket_name" {
  value = module.ci_bucket.heliumedu_s3_bucket_name
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

output "s3_access_key_id" {
  sensitive = true
  value     = module.ci_bucket.s3_access_key_id
}

output "s3_access_key_secret" {
  sensitive = true
  value     = module.ci_bucket.s3_access_key_secret
}
