# modules/timestream/main.tf
resource "aws_timestreamwrite_database" "db" {
  database_name = var.database_name
  tags = {
    Name = "${var.database_name}-${var.region}"
  }
}

resource "aws_timestreamwrite_table" "table" {
  database_name = aws_timestreamwrite_database.db.database_name
  table_name    = var.table_name
  
  retention_properties {
    memory_store_retention_period_in_hours = var.memory_retention_hours
    magnetic_store_retention_period_in_days = var.magnetic_retention_days
  }

  tags = {
    Name = "${var.table_name}-${var.region}"
  }
}