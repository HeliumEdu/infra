resource "random_password" "platform_secret" {
  length  = 50
  special = true
}

resource "aws_secretsmanager_secret" "helium" {
  name = "${var.environment}/helium"
}

data "aws_iam_policy_document" "helium_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [var.task_execution_role_arn]
    }

    actions   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
    resources = ["arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_id}:secret:${var.environment}/helium**"]
  }
}

resource "aws_secretsmanager_secret_policy" "helium_policy" {
  secret_arn = aws_secretsmanager_secret.helium.arn
  policy     = data.aws_iam_policy_document.helium_policy.json
}

resource "aws_secretsmanager_secret_version" "helium_secret_version" {
  secret_id = aws_secretsmanager_secret.helium.id
  secret_string = jsonencode(sensitive({
    PLATFORM_EMAIL_HOST_USER               = var.smtp_email_user
    PLATFORM_EMAIL_HOST_PASSWORD           = var.smtp_email_password
    PLATFORM_TWILIO_ACCOUNT_SID            = var.twilio_account_sid
    PLATFORM_TWILIO_AUTH_TOKEN             = var.twilio_auth_token
    PLATFORM_TWILIO_SMS_FROM               = var.twilio_phone_number
    PLATFORM_AWS_S3_ACCESS_KEY_ID          = var.s3_user_access_key_id
    PLATFORM_AWS_S3_SECRET_ACCESS_KEY      = var.s3_user_secret_access_key
    PLATFORM_REDIS_HOST                    = "redis://${var.redis_host}"
    PLATFORM_DB_HOST                       = var.db_host
    PLATFORM_DB_USER                       = var.db_user
    PLATFORM_DB_PASSWORD                   = var.db_password
    PLATFORM_SECRET_KEY                    = random_password.platform_secret.result
    PROJECT_DATADOG_API_KEY                = var.datadog_api_key
    PLATFORM_SENTRY_DSN                    = var.platform_sentry_dsn
    PLATFORM_FIREBASE_PROJECT_ID           = var.firebase_project_id
    PLATFORM_FIREBASE_PRIVATE_KEY_ID       = var.firebase_private_key_id
    PLATFORM_FIREBASE_PRIVATE_KEY          = var.firebase_private_key
    PLATFORM_FIREBASE_CLIENT_EMAIL         = var.firebase_client_email
    PLATFORM_FIREBASE_CLIENT_ID            = var.firebase_client_id
    PLATFORM_FIREBASE_CLIENT_X509_CERT_URL = var.firebase_client_x509_cert_url
    AWS_INTEGRATION_S3_ACCESS_KEY_ID       = var.integration_s3_access_key_id
    AWS_INTEGRATION_S3_SECRET_ACCESS_KEY   = var.integration_s3_secret_access_key
  }))
}
