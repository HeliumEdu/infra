// IAM user for platform S3 access (media, static files, etc.)
resource "aws_iam_user" "s3_user" {
  name = "helium-${var.environment}-s3-user"
}

resource "aws_iam_access_key" "s3_access_key" {
  user = aws_iam_user.s3_user.name
}

data "aws_iam_policy_document" "helium_s3" {
  statement {
    resources = [
      "arn:aws:s3:::heliumedu.${var.environment}**",
      "arn:aws:s3:::heliumedu.${var.environment}/**",
      "arn:aws:s3:::heliumedu.${var.environment}.*/**",
    ]
    actions = ["s3:*"]
  }
}

resource "aws_iam_policy" "s3_access" {
  name   = "helium-${var.environment}-s3-access"
  policy = data.aws_iam_policy_document.helium_s3.json
}

resource "aws_iam_user_policy_attachment" "s3_access_attachment" {
  user       = aws_iam_user.s3_user.name
  policy_arn = aws_iam_policy.s3_access.arn
}

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

// ALB access logs bucket
resource "aws_s3_bucket" "helium_alb_logs" {
  bucket = "heliumedu.${var.environment}.alb.logs"
}

resource "aws_s3_bucket_public_access_block" "helium_alb_logs_block_public" {
  bucket = aws_s3_bucket.helium_alb_logs.id

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

// Get the ELB service account for the current region
data "aws_elb_service_account" "main" {}

data "aws_iam_policy_document" "helium_alb_logs_allow_elb_delivery" {
  statement {
    sid = "AllowALBLogDelivery"

    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }

    actions = ["s3:PutObject"]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.helium_alb_logs.bucket}/alb/${var.environment}/AWSLogs/${var.aws_account_id}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "helium_alb_logs_allow_elb_delivery" {
  bucket = aws_s3_bucket.helium_alb_logs.id
  policy = data.aws_iam_policy_document.helium_alb_logs_allow_elb_delivery.json

  depends_on = [aws_s3_bucket_public_access_block.helium_alb_logs_block_public]
}

resource "aws_s3_bucket_lifecycle_configuration" "helium_alb_logs_lifecycle" {
  bucket = aws_s3_bucket.helium_alb_logs.id

  rule {
    id     = "expire-old-logs"
    status = "Enabled"

    expiration {
      days = 30
    }
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

// CI preview bucket

resource "aws_s3_bucket" "heliumedu_ci_frontend_app_static" {
  count = var.environment == "prod" ? 1 : 0

  bucket = "heliumedu.ci.frontend-app.static"
}

resource "aws_s3_bucket_public_access_block" "heliumedu_ci_frontend_app_static_allow_public" {
  count = var.environment == "prod" ? 1 : 0

  bucket = aws_s3_bucket.heliumedu_ci_frontend_app_static[0].id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "heliumedu_ci_frontend_app_static_allow_http_access" {
  count = var.environment == "prod" ? 1 : 0

  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    resources = [
      "arn:aws:s3:::heliumedu.ci.frontend-app.static/**",
    ]

    actions = [
      "s3:GetObject"
    ]
  }
}

resource "aws_s3_bucket_policy" "heliumedu_ci_frontend_app_static_allow_http_access" {
  count = var.environment == "prod" ? 1 : 0

  bucket = aws_s3_bucket.heliumedu_ci_frontend_app_static[0].id
  policy = data.aws_iam_policy_document.heliumedu_ci_frontend_app_static_allow_http_access[0].json

  depends_on = [aws_s3_bucket_public_access_block.heliumedu_ci_frontend_app_static_allow_public]
}

resource "aws_s3_bucket_cors_configuration" "heliumedu_ci_frontend_app_static" {
  count = var.environment == "prod" ? 1 : 0

  bucket = aws_s3_bucket.heliumedu_ci_frontend_app_static[0].id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_website_configuration" "heliumedu_ci_frontend_app" {
  count = var.environment == "prod" ? 1 : 0

  bucket = aws_s3_bucket.heliumedu_ci_frontend_app_static[0].id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}
