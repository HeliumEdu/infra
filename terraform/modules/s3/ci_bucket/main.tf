resource "aws_s3_bucket" "heliumedu" {
  bucket = "heliumedu.${var.environment}"
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
      type = "Service"
      identifiers = ["ses.amazonaws.com"]
    }

    resources = [
      "arn:aws:s3:::heliumedu.${var.environment}/ci.email/**",
    ]

    actions = [
      "s3:PutObject"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:Referer"
      values = [var.aws_account_id]
    }
  }
}

resource "aws_s3_bucket_policy" "allow_ses_access" {
  bucket = aws_s3_bucket.heliumedu.id
  policy = data.aws_iam_policy_document.allow_ses_access.json
}