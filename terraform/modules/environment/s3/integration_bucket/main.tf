// Integration bucket - shared across all environments for CI email polling
resource "aws_s3_bucket" "integration" {
  bucket = "heliumedu-integration"

  tags = {
    Environment = "N/A"
  }
}

resource "aws_s3_bucket_cors_configuration" "integration" {
  bucket = aws_s3_bucket.integration.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD", "DELETE"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "integration_lifecycle" {
  bucket = aws_s3_bucket.integration.id

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
  bucket = aws_s3_bucket.integration.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "integration_allow_ses_access" {
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
  bucket = aws_s3_bucket.integration.id
  policy = data.aws_iam_policy_document.integration_allow_ses_access.json
}

resource "aws_iam_user" "integration_s3_user" {
  name = "helium-integration-s3-user"
}

resource "aws_iam_access_key" "integration_s3_access_key" {
  user = aws_iam_user.integration_s3_user.name
}

data "aws_iam_policy_document" "integration_s3" {
  statement {
    resources = [
      "arn:aws:s3:::heliumedu-integration",
      "arn:aws:s3:::heliumedu-integration/*",
    ]
    actions = ["s3:*"]
  }
}

resource "aws_iam_policy" "integration_s3_access" {
  name   = "helium-integration-s3-access"
  policy = data.aws_iam_policy_document.integration_s3.json
}

resource "aws_iam_user_policy_attachment" "integration_s3_access_attachment" {
  user       = aws_iam_user.integration_s3_user.name
  policy_arn = aws_iam_policy.integration_s3_access.arn
}
