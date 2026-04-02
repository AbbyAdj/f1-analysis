output "snowflake_access_key" {
  value = aws_iam_access_key.snowflake_user_key.id
  sensitive = true
}

output "snowflake_secret_key" {
  value = aws_iam_access_key.snowflake_user_key.secret
  sensitive = true
}