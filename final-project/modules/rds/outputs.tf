# ===========================================
# Endpoints для підключення
# ===========================================
#
# Ці outputs використовуються для підключення додатків до БД.

output "endpoint" {
  description = "Endpoint для підключення до БД (host:port або host для Aurora)"
  value = var.use_aurora ? (
    # Для Aurora - endpoint кластеру
    length(aws_rds_cluster.main) > 0 ? aws_rds_cluster.main[0].endpoint : null
  ) : (
    # Для RDS - endpoint інстансу
    length(aws_db_instance.main) > 0 ? aws_db_instance.main[0].endpoint : null
  )
}

output "reader_endpoint" {
  description = "Reader endpoint для read-only з'єднань (тільки для Aurora)"
  value       = var.use_aurora && length(aws_rds_cluster.main) > 0 ? aws_rds_cluster.main[0].reader_endpoint : null
}

output "port" {
  description = "Порт бази даних (5432 для PostgreSQL, 3306 для MySQL)"
  value       = local.db_port
}

# ===========================================
# Інформація про базу даних
# ===========================================
#
# Credentials та назва БД для конфігурації додатків.

output "db_name" {
  description = "Назва бази даних"
  value       = var.db_name
}

output "db_username" {
  description = "Master username для підключення"
  value       = var.db_username
}

output "db_password" {
  description = "Master password для підключення (чутливі дані)"
  value       = local.master_password
  sensitive   = true # не показувати в terraform output
}

# ===========================================
# Ідентифікатори ресурсів
# ===========================================
#
# ID ресурсів для інтеграції з іншими модулями.

output "identifier" {
  description = "Ідентифікатор бази даних"
  value       = var.identifier
}

output "db_instance_id" {
  description = "ID RDS інстансу (null для Aurora)"
  value       = !var.use_aurora && length(aws_db_instance.main) > 0 ? aws_db_instance.main[0].id : null
}

output "cluster_id" {
  description = "ID Aurora кластеру (null для RDS)"
  value       = var.use_aurora && length(aws_rds_cluster.main) > 0 ? aws_rds_cluster.main[0].id : null
}

# ===========================================
# Мережеві ресурси
# ===========================================
#
# ID створених мережевих ресурсів.

output "security_group_id" {
  description = "ID Security Group (для додавання інших правил)"
  value       = aws_security_group.main.id
}

output "subnet_group_name" {
  description = "Назва DB Subnet Group"
  value       = aws_db_subnet_group.main.name
}

# ===========================================
# Connection string для зручності
# ===========================================
#
# Готовий connection string для підключення.
# УВАГА: пароль замінено на PASSWORD - не відображаємо в output!

output "connection_string" {
  description = "Connection string для підключення (password = PASSWORD, замініть на справжній)"
  value = var.use_aurora ? (
    length(aws_rds_cluster.main) > 0 ?
    "${contains(["aurora-postgresql"], var.engine) ? "postgresql" : "mysql"}://${var.db_username}:PASSWORD@${aws_rds_cluster.main[0].endpoint}:${local.db_port}/${var.db_name}" : null
  ) : (
    length(aws_db_instance.main) > 0 ?
    "${contains(["postgres"], var.engine) ? "postgresql" : "mysql"}://${var.db_username}:PASSWORD@${aws_db_instance.main[0].endpoint}/${var.db_name}" : null
  )
}
