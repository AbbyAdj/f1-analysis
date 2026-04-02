# S3 BUCKET

resource "aws_s3_bucket" "snowflake_raw" {
  bucket = var.raw_s3_bucket
  force_destroy = var.force_destroy

  tags = {
    Platform    = "Snowflake"
    Environment = "Dev"
  }
}

# SNOWFLAKE S3 ACCESS

resource "aws_iam_user" "snowflake_user" {
  name = "snowflake_user"

  tags = {
    Platform = "Snowflake"
  }
}

resource "aws_iam_access_key" "snowflake_user_key" {
  user = aws_iam_user.snowflake_user.name
}

data "aws_iam_policy_document" "snowflake_user_policy_document" {
  statement {
    effect    = "Allow"
    actions   = [
              "s3:PutObject",
              "s3:GetObject",
              "s3:GetObjectVersion",
              "s3:DeleteObject",
              "s3:DeleteObjectVersion"
            ]
    resources = ["${aws_s3_bucket.snowflake_raw.arn}/*"]
  }

  statement {
    effect    = "Allow"
    actions   = [
              "s3:ListBucket",
              "s3:GetBucketLocation"
            ]
    resources = [aws_s3_bucket.snowflake_raw.arn]
    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["*"]
        }
    }
}

resource "aws_iam_user_policy" "snowflake_user_policy" {
  name   = "snowflake_user_policy"
  user   = aws_iam_user.snowflake_user.name
  policy = data.aws_iam_policy_document.snowflake_user_policy_document.json
}