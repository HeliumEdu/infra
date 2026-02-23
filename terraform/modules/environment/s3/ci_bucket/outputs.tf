output "heliumedu_s3_bucket_name" {
  value = aws_s3_bucket.heliumedu.bucket
}

output "s3_access_key_id" {
  sensitive = true
  value     = aws_iam_access_key.s3_access_key.id
}

output "s3_access_key_secret" {
  sensitive = true
  value     = aws_iam_access_key.s3_access_key.secret
}