# Головний файл конфігурації - підключення всіх модулів

# 1. Модуль S3 Backend
# Створює S3 bucket для state та DynamoDB для блокувань
module "s3_backend" {
  source = "./modules/s3-backend"

  # Ім'я bucket має бути глобально унікальним!
  # Формат: [назва проєкту / тікету]-[ім'я / псевдонім / ініціали]-[дата]
  bucket_name = "goit-lesson5-tfstate-andriy-pro-20251202"
  table_name  = "terraform-locks"
}

# 2. Модуль VPC
# Створює мережеву інфраструктуру
module "vpc" {
  source = "./modules/vpc"

  vpc_name           = "lesson-5-vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  availability_zones = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

# 3. Модуль ECR
# Створює Docker registry
module "ecr" {
  source = "./modules/ecr"

  ecr_name     = "lesson-5-ecr"
  scan_on_push = true
}
