# modules/timestream/outputs.tf
output "database_name" {
  value = aws_timestreamwrite_database.db.database_name
}

output "table_name" {
  value = aws_timestreamwrite_table.table.table_name
}

output "database_arn" {
  value = aws_timestreamwrite_database.db.arn
}

output "table_arn" {
  value = aws_timestreamwrite_table.table.arn
}