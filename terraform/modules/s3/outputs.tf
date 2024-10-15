output "heliumedu_s3_bucket_name" {
  value = module.ci_bucket.heliumedu_s3_bucket_name
}

output "s3_access_key_id" {
  sensitive = true
  value = aws_iam_access_key.s3_access_key.id
}

output "s3_access_key_secret" {
  sensitive = true
  value     = aws_iam_access_key.s3_access_key.secret
}