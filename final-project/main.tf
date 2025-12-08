# ===========================================
# Фінальний проєкт: Головний файл конфігурації
# ===========================================
# Підключення всіх модулів для розгортання
# повної DevOps інфраструктури на AWS

# --- Локальні змінні ---
locals {
  project_name = "final-project"
  cluster_name = "${local.project_name}-eks"
  region       = "eu-north-1"

  # Загальні теги для всіх ресурсів
  common_tags = {
    Project     = local.project_name
    Environment = "learning"
    ManagedBy   = "terraform"
  }
}

# ===========================================
# 1. S3 Backend Module
# ===========================================
# S3 бакет для зберігання Terraform state
# DynamoDB таблиця для блокування state
module "s3_backend" {
  source = "./modules/s3-backend"

  bucket_name = "goit-final-project-andriy-pro-20251208"
  table_name  = "terraform-locks-final-project"
}

# ===========================================
# 2. VPC Module
# ===========================================
# Віртуальна приватна мережа з public/private subnets
# Для EKS та RDS
module "vpc" {
  source = "./modules/vpc"

  vpc_name           = "${local.project_name}-vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  availability_zones = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  cluster_name       = local.cluster_name
}

# ===========================================
# 3. ECR Module
# ===========================================
# Docker registry для Django images
module "ecr" {
  source = "./modules/ecr"

  ecr_name     = "${local.project_name}-django"
  scan_on_push = true
}

# ===========================================
# 4. EKS Module
# ===========================================
# Kubernetes кластер для всіх застосунків
module "eks" {
  source = "./modules/eks"

  cluster_name       = local.cluster_name
  kubernetes_version = "1.30"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids

  # SPOT інстанси - дешевше на 60-90%
  capacity_type  = "SPOT"
  instance_types = ["t3.medium", "t3.small"]

  # 3 nodes для розміщення всіх компонентів (Jenkins, ArgoCD, Monitoring)
  desired_nodes = 3
  min_nodes     = 3
  max_nodes     = 5
}

# ===========================================
# 5. RDS Module (PostgreSQL)
# ===========================================
# Керована база даних для Django
module "rds" {
  source = "./modules/rds"

  identifier     = "${local.project_name}-postgres"
  use_aurora     = false          # RDS Instance (дешевше)
  engine         = "postgres"
  engine_version = "15.15"
  instance_class = "db.t3.micro"  # Free Tier eligible
  multi_az       = false          # Для dev/test

  db_name     = "djangodb"
  db_username = "dbadmin"
  # db_password генерується автоматично

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  # Дозволити доступ від EKS nodes
  allowed_security_groups = [module.eks.node_security_group_id]

  # Налаштування для dev/test
  skip_final_snapshot     = true
  deletion_protection     = false
  backup_retention_period = 1

  tags = local.common_tags
}

# ===========================================
# 6. Jenkins Module
# ===========================================
# CI/CD сервер для build та push Docker images
module "jenkins" {
  source = "./modules/jenkins"

  eks_dependency = module.eks
}

# ===========================================
# 7. Argo CD Module
# ===========================================
# GitOps інструмент для deployment
module "argo_cd" {
  source = "./modules/argo-cd"

  eks_dependency = module.eks
}

# ===========================================
# 8. Monitoring Module (Prometheus + Grafana)
# ===========================================
# Збір та візуалізація метрик
module "monitoring" {
  source = "./modules/monitoring"

  eks_dependency = module.eks
}

