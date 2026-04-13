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
resource "aws_iam_role" "snowflake_s3_access_role" {
  name = "snowflake_s3_access_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          AWS = var.snowflake_iam_user_arn != "" ? var.snowflake_iam_user_arn : data.aws_caller_identity.current.account_id
        }
        Condition = {
            StringEquals = {
              "sts:ExternalId" = var.snowflake_external_id != "" ? var.snowflake_external_id : "0000"
          }
        }
      }
    ]
  })
  
}

data "aws_iam_policy_document" "snowflake_role_policy_document" {
  statement {
    effect    = "Allow"
    actions   = [
              "s3:PutObject",
              "s3:GetObject",
              "s3:GetObjectVersion",
              "s3:DeleteObject",
              "s3:DeleteObjectVersion"
            ]
    resources = ["${aws_s3_bucket.snowflake_raw.arn}/raw/*"]
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
      values   = ["raw/*"]
        }
    }
}

resource "aws_iam_role_policy" "snowflake_role_policy" {
  name   = "snowflake_s3_access_policy"
  role   = aws_iam_role.snowflake_s3_access_role.name
  policy = data.aws_iam_policy_document.snowflake_role_policy_document.json
}

# User Data
data "aws_caller_identity" "current" {}