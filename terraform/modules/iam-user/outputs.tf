# modules/iam-user/outputs.tf
output "user_name" {
  value = aws_iam_user.timestream_user.name
}

output "access_key_id" {
  value     = aws_iam_access_key.timestream_user_key.id
  sensitive = true
}

output "secret_access_key" {
  value     = aws_iam_access_key.timestream_user_key.secret
  sensitive = true
}