# modules/iam-user/variables.tf
variable "user_name" {
  description = "Name of the IAM user"
  type        = string
}

variable "timestream_resources" {
  description = "List of Timestream resource ARNs to grant access"
  type        = list(string)
}