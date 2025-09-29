module "ci_bucket" {
  source = "./ci_bucket"

  aws_account_id = var.aws_account_id
  environment    = var.environment
}

resource "aws_s3_bucket" "heliumedu" {
  count = var.environment == "prod" ? 1 : 0

  bucket = "heliumedu"

  tags = {
    Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "heliumedu_block_public" {
  bucket = aws_s3_bucket.heliumedu[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
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
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET"]
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
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.heliumedu_frontend_static.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }
}
