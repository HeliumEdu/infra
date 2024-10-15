resource "aws_secretsmanager_secret" "helium" {
  name = "${var.environment}/helium"
}

resource "aws_secretsmanager_secret_version" "helium_secret_version" {
  secret_id = aws_secretsmanager_secret.helium.id
  secret_string = jsonencode(sensitive({
    PLATFORM_EMAIL_HOST_USER     = var.smtp_email_user
    PLATFORM_EMAIL_HOST_PASSWORD = var.smtp_email_password
  }))
}