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
  secret_string = jsonencode(merge(
    {
      PLATFORM_EMAIL_HOST_USER               = var.smtp_email_user
      PLATFORM_EMAIL_HOST_PASSWORD           = var.smtp_email_password
      PLATFORM_AWS_S3_ACCESS_KEY_ID          = var.s3_user_access_key_id
      PLATFORM_AWS_S3_SECRET_ACCESS_KEY      = var.s3_user_secret_access_key
      PLATFORM_REDIS_HOST                    = "rediss://:${var.redis_auth_token}@${var.redis_host}:6379?ssl_cert_reqs=required"
      PLATFORM_DB_HOST                       = var.db_host
      PLATFORM_DB_USER                       = var.db_user
      PLATFORM_DB_PASSWORD                   = var.db_password
      PLATFORM_SECRET_KEY                    = random_password.platform_secret.result
      PROJECT_DATADOG_API_KEY                = var.datadog_api_key
      PLATFORM_FIREBASE_PROJECT_ID           = var.firebase_project_id
      PLATFORM_FIREBASE_PRIVATE_KEY_ID       = var.firebase_private_key_id
      PLATFORM_FIREBASE_PRIVATE_KEY          = var.firebase_private_key
      PLATFORM_FIREBASE_CLIENT_EMAIL         = var.firebase_client_email
      PLATFORM_FIREBASE_CLIENT_ID            = var.firebase_client_id
      PLATFORM_FIREBASE_CLIENT_X509_CERT_URL = var.firebase_client_x509_cert_url
    },
    var.ci_app_host != null ? { PROJECT_CI_APP_HOST = "https://${var.ci_app_host}" } : {},
    var.sentry_dsn != null ? { PLATFORM_SENTRY_DSN = var.sentry_dsn } : {},
    var.jsm_api_token != null ? { PLATFORM_JSM_API_TOKEN = var.jsm_api_token } : {},
    var.ga4_measurement_id != null ? { PLATFORM_GA4_MEASUREMENT_ID = var.ga4_measurement_id } : {},
    var.ga4_api_secret != null ? { PLATFORM_GA4_API_SECRET = var.ga4_api_secret } : {},
  ))
}
