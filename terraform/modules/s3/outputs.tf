output "heliumedu_s3_bucket_name" {
  value = module.ci_bucket.heliumedu_s3_bucket_name
}

output "s3_access_key_id" {
  sensitive = true
  value     = module.ci_bucket.s3_access_key_id
}

output "s3_access_key_secret" {
  sensitive = true
  value     = module.ci_bucket.s3_access_key_secret
}