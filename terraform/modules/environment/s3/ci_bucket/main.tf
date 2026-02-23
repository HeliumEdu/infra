resource "aws_s3_bucket" "heliumedu" {
  bucket = "heliumedu.${var.environment}"
}

resource "aws_s3_bucket_lifecycle_configuration" "heliumedu_lifecycle" {
  bucket = aws_s3_bucket.heliumedu.id

  rule {
    id = "inbound-email"

    filter {
      prefix = "inbound.email/"
    }
    expiration {
      days = 7
    }

    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "heliumedu_block_public" {
  bucket = aws_s3_bucket.heliumedu.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "allow_ses_access" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["ses.amazonaws.com"]
    }

    resources = [
      "arn:aws:s3:::heliumedu.${var.environment}/inbound.email/**",
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

resource "aws_s3_bucket_policy" "allow_ses_access" {
  bucket = aws_s3_bucket.heliumedu.id
  policy = data.aws_iam_policy_document.allow_ses_access.json
}

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
    "arn:aws:s3:::heliumedu.${var.environment}.*/**"]
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
