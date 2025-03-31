# modules/iam-user/main.tf
resource "aws_iam_user" "timestream_user" {
  name = var.user_name
  tags = {
    Name = var.user_name
  }
}

resource "aws_iam_access_key" "timestream_user_key" {
  user = aws_iam_user.timestream_user.name
}

resource "aws_iam_user_policy" "timestream_access" {
  name = "timestream-access-policy"
  user = aws_iam_user.timestream_user.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "timestream:WriteRecords",
          "timestream:DescribeDatabase",
          "timestream:DescribeTable",
          "timestream:Select",
          "timestream:DescribeEndpoints"
        ]
        Resource = "*"
      }
    ]
  })
}