resource "aws_s3_bucket" "heliumedu_ci_frontend_app_static" {
  count = var.environment == "prod" ? 1 : 0

  bucket = "heliumedu.ci.frontend-app.static"

  tags = {
    Environment = "ci"
  }
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
