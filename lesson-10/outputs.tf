# ===========================================
# VPC Outputs
# ===========================================

output "vpc_id" {
  description = "ID створеного VPC"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "ID приватних підмереж"
  value       = module.vpc.private_subnet_ids
}

# ===========================================
# RDS PostgreSQL Outputs
# ===========================================
#
# Ці значення потрібні для підключення до БД.

output "rds_endpoint" {
  description = "RDS endpoint для підключення (host:port)"
  value       = module.rds_postgres.endpoint
}

output "rds_port" {
  description = "Порт БД (5432 для PostgreSQL)"
  value       = module.rds_postgres.port
}

output "rds_db_name" {
  description = "Назва бази даних"
  value       = module.rds_postgres.db_name
}

output "rds_username" {
  description = "Username для підключення"
  value       = module.rds_postgres.db_username
}

output "rds_password" {
  description = "Password для підключення (sensitive - не показується в output)"
  value       = module.rds_postgres.db_password
  sensitive   = true
}

output "rds_connection_string" {
  description = "Connection string (password замінено на PASSWORD)"
  value       = module.rds_postgres.connection_string
}

output "rds_security_group_id" {
  description = "ID Security Group (для додавання правил)"
  value       = module.rds_postgres.security_group_id
}

# ===========================================
# Aurora Outputs
# ===========================================
#
# Розкоментуйте якщо використовуєте Aurora модуль.

# output "aurora_endpoint" {
#   description = "Aurora writer endpoint"
#   value       = module.aurora_postgres.endpoint
# }
#
# output "aurora_reader_endpoint" {
#   description = "Aurora reader endpoint для read-only запитів"
#   value       = module.aurora_postgres.reader_endpoint
# }
#
# output "aurora_port" {
#   description = "Порт БД (5432 для PostgreSQL)"
#   value       = module.aurora_postgres.port
# }
#
# output "aurora_db_name" {
#   description = "Назва бази даних"
#   value       = module.aurora_postgres.db_name
# }
#
# output "aurora_username" {
#   description = "Username для підключення"
#   value       = module.aurora_postgres.db_username
# }
#
# output "aurora_password" {
#   description = "Password для підключення"
#   value       = module.aurora_postgres.db_password
#   sensitive   = true
# }
#
# output "aurora_connection_string" {
#   description = "Connection string"
#   value       = module.aurora_postgres.connection_string
# }
#
# output "aurora_security_group_id" {
#   description = "ID Security Group"
#   value       = module.aurora_postgres.security_group_id
# }
