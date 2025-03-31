
provider "aws" {
  region  = var.region
  profile = var.profile
  default_tags {
    tags = var.default_tags
  }
}

module "vpc" {
    source = "./modules/vpc"
    vpc_cidr = var.vpc_cidr
    subnets = var.subnets
    region = var.region
    availability_zones = var.availability_zones
}

module "timestream" {
  source                  = "./modules/timestream"
  region                  = var.region
  database_name           = var.timestream_db_name
  table_name              = var.timestream_table_name
  memory_retention_hours  = var.timestream_memory_retention_hours
  magnetic_retention_days = var.timestream_magnetic_retention_days
}

# Módulo IAM User (criado apenas se create_user = true)
module "iam_user" {
  source             = "./modules/iam-user"
  user_name          = var.iam_user_name
  timestream_resources = [module.timestream.database_arn, module.timestream.table_arn]
}

output "iam_access_key_id" {
  value     = module.iam_user.access_key_id
  sensitive = true
}

output "iam_secret_access_key" {
  value     = module.iam_user.secret_access_key
  sensitive = true
}

output "iam_user_name" {
  value = module.iam_user.user_name
}

output "database_name" {
  value = module.timestream.database_name
}

output "table_name" {
  value = module.timestream.table_name
}

output "timestream_database_arn" {
  value = module.timestream.database_arn
}

output "timestream_table_arn" {
  value = module.timestream.table_arn
}