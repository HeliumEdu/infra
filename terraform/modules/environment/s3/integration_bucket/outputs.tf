output "bucket_name" {
  value = aws_s3_bucket.integration.bucket
}

output "access_key_id" {
  sensitive = true
  value     = aws_iam_access_key.integration_s3_access_key.id
}

output "secret_access_key" {
  sensitive = true
  value     = aws_iam_access_key.integration_s3_access_key.secret
}
