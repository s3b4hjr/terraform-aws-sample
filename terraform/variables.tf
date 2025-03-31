variable "region" {
  description = "AWS region"
  type        = string
}

variable "profile" {
  description = "AWS profile"
  type        = string
}
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "subnets" {
  description = "Map of subnet names to CIDR blocks"
  type        = map(string)
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "timestream_db_name" {
  description = "Name of the Timestream database"
  type        = string
  default     = "example-timestream-db"
}

variable "timestream_table_name" {
  description = "Name of the Timestream table"
  type        = string
  default     = "example-table"
}

variable "timestream_memory_retention_hours" {
  description = "Retention period in hours for the memory store"
  type        = number
  default     = 24
}

variable "timestream_magnetic_retention_days" {
  description = "Retention period in days for the magnetic store"
  type        = number
  default     = 7
}

variable "iam_user_name" {
  description = "Name of the IAM user"
  type        = string
  default     = "timestream-app-user"
}

variable "default_tags" {
  default = {
    project     = "corretora"
    environment = "dev"
  }
}