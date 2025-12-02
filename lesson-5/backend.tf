# Конфігурація Terraform Backend
#
# ПРОБЛЕМА "КУРКИ І ЯЙЦЯ":
# Щоб зберігати state в S3, потрібен S3 bucket.
# Але S3 bucket створюється через Terraform.
# Хто перший?
#
# РІШЕННЯ:
# 1. Спочатку запускаємо з локальним state (цей файл закоментований)
# 2. terraform apply створює S3 bucket
# 3. Розкоментовуємо backend та запускаємо terraform init -migrate-state
#
# ПІСЛЯ УСПІШНОГО terraform apply розкоментовуємо блок нижче

# terraform {
#   backend "s3" {
#     bucket         = "goit-lesson5-tfstate-andriy-pro-20251202"
#     key            = "lesson-5/terraform.tfstate"
#     region         = "eu-north-1"
#     dynamodb_table = "terraform-locks"
#     encrypt        = true
#   }
# }
