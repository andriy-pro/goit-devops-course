# Вихідні значення проєкту
# (відображаються після terraform apply)

# S3 Backend
output "s3_bucket_name" {
  description = "Ім'я S3 bucket для Terraform state"
  value       = module.s3_backend.bucket_name
}

output "dynamodb_table_name" {
  description = "Ім'я DynamoDB таблиці для блокувань"
  value       = module.s3_backend.dynamodb_table_name
}

# VPC
output "vpc_id" {
  description = "ID створеного VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "ID публічних підмереж"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "ID приватних підмереж"
  value       = module.vpc.private_subnet_ids
}

# ECR
output "ecr_repository_url" {
  description = "URL ECR репозиторію"
  value       = module.ecr.repository_url
}
