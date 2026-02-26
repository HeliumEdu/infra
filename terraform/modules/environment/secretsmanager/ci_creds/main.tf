resource "aws_secretsmanager_secret" "helium" {
  name = "${var.environment}/helium"
}

resource "aws_secretsmanager_secret_version" "helium_secret_version" {
  secret_id = aws_secretsmanager_secret.helium.id
  secret_string = jsonencode(sensitive({
    PLATFORM_EMAIL_HOST_USER             = var.smtp_email_user
    PLATFORM_EMAIL_HOST_PASSWORD         = var.smtp_email_password
    AWS_INTEGRATION_S3_ACCESS_KEY_ID     = var.integration_s3_access_key_id
    AWS_INTEGRATION_S3_SECRET_ACCESS_KEY = var.integration_s3_secret_access_key
  }))
}
