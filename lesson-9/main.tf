# Головний файл конфігурації - підключення всіх модулів

# ============================================
# Локальні змінні
# ============================================
locals {
  cluster_name = "lesson-9-eks"
}

# ============================================
# 1. S3 Backend Module
# ============================================
module "s3_backend" {
  source = "./modules/s3-backend"

  bucket_name = "goit-lesson-9-andriy-pro-20251205"
  table_name  = "terraform-locks-lesson-9"
}

# ============================================
# 2. VPC Module (з EKS тегами)
# ============================================
module "vpc" {
  source = "./modules/vpc"

  vpc_name           = "lesson-9-vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  availability_zones = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  cluster_name       = local.cluster_name
}

# ============================================
# 3. ECR Module
# ============================================
module "ecr" {
  source = "./modules/ecr"

  ecr_name     = "lesson-9-django"
  scan_on_push = true
}

# ============================================
# 4. EKS Module
# ============================================
module "eks" {
  source = "./modules/eks"

  cluster_name       = local.cluster_name
  kubernetes_version = "1.30" # Оновлено з 1.28 (End of Support)
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids

  instance_types = ["t3.medium"]
  desired_nodes  = 2
  min_nodes      = 2
  max_nodes      = 4
}

# ============================================
# 5. Jenkins Module
# ============================================
module "jenkins" {
  source = "./modules/jenkins"

  eks_dependency = module.eks
}

# ============================================
# 6. Argo CD Module
# ============================================
module "argo_cd" {
  source = "./modules/argo-cd"

  eks_dependency = module.eks
}
