module "ci_bucket" {
  source = "./ci_bucket"

  aws_account_id = var.aws_account_id
  environment    = var.environment
}

resource "aws_iam_user" "s3_user" {
  name = "${var.environment}_helium_s3_user"
}

resource "aws_iam_access_key" "s3_access_key" {
  user = aws_iam_user.s3_user.name
}

output "s3_access_key_id" {
  value = aws_iam_access_key.s3_access_key.id
}

output "s3_access_key_secret" {
  sensitive = true
  value     = aws_iam_access_key.s3_access_key.secret
}

data "aws_iam_policy_document" "helium_s3" {
  statement {
    resources = ["arn:aws:s3:::heliumedu.${var.environment}**"]
    actions = ["s3:*"]
  }
}

resource "aws_iam_policy" "ses_sender" {
  name   = "AWSS3HeliumPolicy"
  policy = data.aws_iam_policy_document.helium_s3.json
}

resource "aws_s3_bucket" "heliumedu_static" {
  bucket = "heliumedu.${var.environment}.static"
}

data "aws_iam_policy_document" "allow_static_http_access" {
  statement {
    principals {
      type = "*"
      identifiers = ["*"]
    }

    resources = [
      "arn:aws:s3:::heliumedu.${var.environment}.static/**",
    ]

    actions = [
      "s3:GetObject"
    ]
  }
}

resource "aws_s3_bucket_policy" "allow_static_http_access" {
  bucket = aws_s3_bucket.heliumedu_static.id
  policy = data.aws_iam_policy_document.allow_static_http_access.json
}

resource "aws_s3_bucket_cors_configuration" "heliumedu_static" {
  bucket = aws_s3_bucket.heliumedu_static.id

  cors_rule {
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    expose_headers = ["ETag"]
    max_age_seconds = 3000
  }
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
