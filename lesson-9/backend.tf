# УВАГА: Цей файл налаштовується ПІСЛЯ першого terraform apply!
# Проблема "курки і яйця": S3 bucket має існувати перед налаштуванням backend.
#
# Кроки:
# 1. Спочатку backend закоментований → terraform apply (створює S3)
# 2. Потім розкоментувати → terraform init -migrate-state

# terraform {
#   backend "s3" {
#     bucket         = "goit-lesson-9-andriy-pro-20251203"
#     key            = "lesson-9/terraform.tfstate"
#     region         = "eu-north-1"
#     dynamodb_table = "terraform-locks-lesson-9"
#     encrypt        = true
#   }
# }
