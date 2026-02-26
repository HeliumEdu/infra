resource "aws_s3_bucket" "heliumedu_media" {
  bucket = "heliumedu.${var.environment}.media"
}

resource "aws_s3_bucket_public_access_block" "heliumedu_media_block_public" {
  bucket = aws_s3_bucket.heliumedu_media.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "heliumedu_platform_static_allow_http_access" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    resources = [
      "arn:aws:s3:::heliumedu.${var.environment}.platform.static/**",
    ]

    actions = [
      "s3:GetObject"
    ]
  }
}

resource "aws_s3_bucket" "heliumedu_platform_static" {
  bucket = "heliumedu.${var.environment}.platform.static"
}

resource "aws_s3_bucket_public_access_block" "heliumedu_platform_static_allow_public" {
  bucket = aws_s3_bucket.heliumedu_platform_static.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "heliumedu_platform_static_allow_http_access" {
  bucket = aws_s3_bucket.heliumedu_platform_static.id
  policy = data.aws_iam_policy_document.heliumedu_platform_static_allow_http_access.json

  depends_on = [aws_s3_bucket_public_access_block.heliumedu_platform_static_allow_public]
}

resource "aws_s3_bucket_cors_configuration" "heliumedu_platform_static" {
  bucket = aws_s3_bucket.heliumedu_platform_static.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket" "heliumedu_frontend_static" {
  bucket = "heliumedu.${var.environment}.frontend.static"
}

resource "aws_s3_bucket_public_access_block" "heliumedu_frontend_static_allow_public" {
  bucket = aws_s3_bucket.heliumedu_frontend_static.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "heliumedu_frontend_static_allow_http_access" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    resources = [
      "arn:aws:s3:::heliumedu.${var.environment}.frontend.static/**",
    ]

    actions = [
      "s3:GetObject"
    ]
  }
}

resource "aws_s3_bucket_policy" "heliumedu_frontend_static_allow_http_access" {
  bucket = aws_s3_bucket.heliumedu_frontend_static.id
  policy = data.aws_iam_policy_document.heliumedu_frontend_static_allow_http_access.json

  depends_on = [aws_s3_bucket_public_access_block.heliumedu_frontend_static_allow_public]
}

resource "aws_s3_bucket_cors_configuration" "heliumedu_frontend_static" {
  bucket = aws_s3_bucket.heliumedu_frontend_static.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_website_configuration" "heliumedu_frontend" {
  bucket = aws_s3_bucket.heliumedu_frontend_static.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }
}

// Flutter app frontend bucket (app.heliumedu.com)

resource "aws_s3_bucket" "heliumedu_frontend_app_static" {
  bucket = "heliumedu.${var.environment}.frontend-app.static"
}

resource "aws_s3_bucket_public_access_block" "heliumedu_frontend_app_static_allow_public" {
  bucket = aws_s3_bucket.heliumedu_frontend_app_static.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "heliumedu_frontend_app_static_allow_http_access" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    resources = [
      "arn:aws:s3:::heliumedu.${var.environment}.frontend-app.static/**",
    ]

    actions = [
      "s3:GetObject"
    ]
  }
}

resource "aws_s3_bucket_policy" "heliumedu_frontend_app_static_allow_http_access" {
  bucket = aws_s3_bucket.heliumedu_frontend_app_static.id
  policy = data.aws_iam_policy_document.heliumedu_frontend_app_static_allow_http_access.json

  depends_on = [aws_s3_bucket_public_access_block.heliumedu_frontend_app_static_allow_public]
}

resource "aws_s3_bucket_cors_configuration" "heliumedu_frontend_app_static" {
  bucket = aws_s3_bucket.heliumedu_frontend_app_static.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_website_configuration" "heliumedu_frontend_app" {
  bucket = aws_s3_bucket.heliumedu_frontend_app_static.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

// Buckets only created once, for production

resource "aws_s3_bucket" "heliumedu" {
  count = var.environment == "prod" ? 1 : 0

  bucket = "heliumedu"

  tags = {
    Environment = "N/A"
  }
}

resource "aws_s3_bucket_public_access_block" "heliumedu_block_public" {
  count = var.environment == "prod" ? 1 : 0

  bucket = aws_s3_bucket.heliumedu[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

// Integration bucket - shared across all environments for CI email polling
// Only created once, in production

resource "aws_s3_bucket" "integration" {
  count = var.environment == "prod" ? 1 : 0

  bucket = "heliumedu-integration"

  tags = {
    Environment = "N/A"
  }
}

resource "aws_s3_bucket_cors_configuration" "integration" {
  count = var.environment == "prod" ? 1 : 0

  bucket = aws_s3_bucket.integration[0].id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD", "DELETE"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "integration_lifecycle" {
  count = var.environment == "prod" ? 1 : 0

  bucket = aws_s3_bucket.integration[0].id

  rule {
    id = "inbound-email"

    filter {
      prefix = ""
    }
    expiration {
      days = 7
    }

    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "integration_block_public" {
  count = var.environment == "prod" ? 1 : 0

  bucket = aws_s3_bucket.integration[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "integration_allow_ses_access" {
  count = var.environment == "prod" ? 1 : 0

  statement {
    principals {
      type        = "Service"
      identifiers = ["ses.amazonaws.com"]
    }

    resources = [
      "arn:aws:s3:::heliumedu-integration/*",
    ]

    actions = [
      "s3:PutObject"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:Referer"
      values   = [var.aws_account_id]
    }
  }
}

resource "aws_s3_bucket_policy" "integration_allow_ses_access" {
  count = var.environment == "prod" ? 1 : 0

  bucket = aws_s3_bucket.integration[0].id
  policy = data.aws_iam_policy_document.integration_allow_ses_access[0].json
}

resource "aws_iam_user" "integration_s3_user" {
  count = var.environment == "prod" ? 1 : 0

  name = "helium-integration-s3-user"
}

resource "aws_iam_access_key" "integration_s3_access_key" {
  count = var.environment == "prod" ? 1 : 0

  user = aws_iam_user.integration_s3_user[0].name
}

data "aws_iam_policy_document" "integration_s3" {
  count = var.environment == "prod" ? 1 : 0

  statement {
    resources = [
      "arn:aws:s3:::heliumedu-integration",
      "arn:aws:s3:::heliumedu-integration/*",
    ]
    actions = ["s3:*"]
  }
}

resource "aws_iam_policy" "integration_s3_access" {
  count = var.environment == "prod" ? 1 : 0

  name   = "helium-integration-s3-access"
  policy = data.aws_iam_policy_document.integration_s3[0].json
}

resource "aws_iam_user_policy_attachment" "integration_s3_access_attachment" {
  count = var.environment == "prod" ? 1 : 0

  user       = aws_iam_user.integration_s3_user[0].name
  policy_arn = aws_iam_policy.integration_s3_access[0].arn
}
