# ===========================================
# Lesson 10: Гнучкий Terraform-модуль для БД
# ===========================================
#
# Цей файл демонструє використання модуля rds
# для створення RDS PostgreSQL та Aurora Cluster.
#
# УВАГА: RDS коштує гроші! Після тестування виконайте:
# terraform destroy

# ===========================================
# VPC
# ===========================================
#
# Мінімальний VPC з приватними підмережами для RDS.

module "vpc" {
  source = "./modules/vpc"

  vpc_name           = "lesson-10-vpc"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["eu-north-1a", "eu-north-1b"] # 2 AZ для Multi-AZ

  tags = {
    Project = "lesson-10"
  }
}

# ===========================================
# RDS PostgreSQL Instance (use_aurora = false)
# ===========================================
#
# Звичайний RDS інстанс - найпростіший варіант.
# Підходить для dev/test та невеликих production.
#
# Вартість: ~$0.02/год для db.t3.micro

module "rds_postgres" {
  source = "./modules/rds"

  # --- Тип бази даних ---
  identifier     = "lesson-10-postgres"
  use_aurora     = false         # false = RDS Instance
  engine         = "postgres"    # PostgreSQL
  engine_version = "15.4"        # версія PostgreSQL
  instance_class = "db.t3.micro" # найдешевший клас
  multi_az       = false         # без standby (дешевше)

  # --- Credentials ---
  db_name     = "myapp"
  db_username = "admin"
  # db_password не задано - буде згенеровано автоматично

  # --- Мережа ---
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  # Дозволити доступ з всього VPC
  allowed_cidr_blocks = [module.vpc.vpc_cidr]

  # --- Parameter Group налаштування ---
  max_connections = 100   # максимум з'єднань
  log_statement   = "ddl" # логувати DDL запити (CREATE, ALTER, DROP)
  work_mem        = 4096  # 4MB для операцій сортування

  # --- Dev/Test налаштування ---
  # Для production змініть на:
  # skip_final_snapshot = false
  # deletion_protection = true
  # backup_retention_period = 7
  skip_final_snapshot     = true  # не створювати snapshot при видаленні
  deletion_protection     = false # дозволити видалення
  backup_retention_period = 1     # 1 день бекапів

  tags = {
    Project     = "lesson-10"
    Environment = "dev"
  }
}

# ===========================================
# Aurora PostgreSQL Cluster (use_aurora = true)
# ===========================================
#
# ЗАКОМЕНТОВАНО за замовчуванням!
# Розкоментуйте для тестування Aurora.
#
# Aurora дорожча, але має переваги:
# - Автоматичне масштабування сховища
# - Швидший failover (секунди)
# - До 15 read replicas
#
# Вартість: ~$0.08/год для db.t3.medium

# module "aurora_postgres" {
#   source = "./modules/rds"
#
#   # --- Тип бази даних ---
#   identifier     = "lesson-10-aurora"
#   use_aurora     = true                # true = Aurora Cluster
#   engine         = "aurora-postgresql" # Aurora PostgreSQL
#   engine_version = "15.4"
#   instance_class = "db.t3.medium"      # Aurora мінімум t3.medium!
#   multi_az       = false               # true для reader instance
#
#   # --- Credentials ---
#   db_name     = "myapp"
#   db_username = "admin"
#
#   # --- Мережа ---
#   vpc_id     = module.vpc.vpc_id
#   subnet_ids = module.vpc.private_subnet_ids
#
#   allowed_cidr_blocks = [module.vpc.vpc_cidr]
#
#   # --- Parameter Group налаштування ---
#   max_connections = 200
#   log_statement   = "ddl"
#   work_mem        = 8192 # 8MB
#
#   # --- Dev/Test налаштування ---
#   skip_final_snapshot     = true
#   deletion_protection     = false
#   backup_retention_period = 1
#
#   tags = {
#     Project     = "lesson-10"
#     Environment = "dev"
#   }
# }
