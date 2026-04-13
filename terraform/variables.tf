variable "aws_region" {
    description = "The AWS region to deploy resources in"
    type        = string
    default     = "eu-west-2"
}

variable "raw_s3_bucket" {
    description = "The name of the S3 bucket for raw data"
    type        = string
    default     = "abby-snowflake-raw"
}

variable "force_destroy" {
    description = "Whether to force destroy the S3 bucket (delete all objects)"
    type        = bool
    default     = true
}

variable "snowflake_iam_user_arn" {
    description = "The ARN of the Snowflake IAM user"
    type        = string
    default = ""
}

variable "snowflake_external_id" {
    description = "The external ID for the Snowflake IAM role"
    type        = string
    default     = ""
}