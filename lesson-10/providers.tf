# ===========================================
# Terraform та Provider налаштування
# ===========================================
#
# Цей файл визначає:
# - Мінімальну версію Terraform
# - Необхідні провайдери та їх версії
# - Конфігурацію AWS провайдера

terraform {
  # Мінімальна версія Terraform
  required_version = ">= 1.0"

  # Необхідні провайдери
  required_providers {
    # AWS провайдер для створення RDS, VPC тощо
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # версія 5.x
    }
    # Random провайдер для генерації паролів
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

# ===========================================
# AWS Provider
# ===========================================

provider "aws" {
  region = "eu-north-1" # Стокгольм - найближчий до України

  # Теги, які будуть додані до ВСІХ ресурсів
  default_tags {
    tags = {
      Project     = "lesson-10"
      Environment = "learning"
      ManagedBy   = "terraform"
    }
  }
}
