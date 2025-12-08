# ===========================================
# Terraform Backend Configuration
# ===========================================
#
# УВАГА: Цей файл налаштовується ПІСЛЯ першого terraform apply!
# Проблема "курки і яйця": S3 bucket має існувати перед налаштуванням backend.
#
# Кроки:
# 1. Спочатку backend закоментований → terraform apply -target=module.s3_backend
# 2. Потім розкоментувати → terraform init -migrate-state

terraform {
  backend "s3" {
    bucket         = "goit-final-project-andriy-pro-20251208"
    key            = "final-project/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "terraform-locks-final-project"
    encrypt        = true
  }
}
