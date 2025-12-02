# Налаштування Terraform та AWS провайдера

terraform {
  # Мінімальна версія Terraform
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  # Регіон AWS (Стокгольм, Швеція - один з найближчих до України, дешевший за інші)
  region = "eu-north-1"

  # Теги, що додаються до всіх ресурсів автоматично
  default_tags {
    tags = {
      Project     = "lesson-5"
      Environment = "learning"
      ManagedBy   = "terraform"
    }
  }
}
