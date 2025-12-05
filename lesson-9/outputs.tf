# ============================================
# S3 Backend Outputs
# ============================================
output "s3_bucket_name" {
  description = "S3 bucket для Terraform state"
  value       = module.s3_backend.bucket_name
}

# ============================================
# VPC Outputs
# ============================================
output "vpc_id" {
  description = "ID VPC"
  value       = module.vpc.vpc_id
}

# ============================================
# ECR Outputs
# ============================================
output "ecr_repository_url" {
  description = "URL ECR репозиторія"
  value       = module.ecr.repository_url
}

# ============================================
# EKS Outputs
# ============================================
output "eks_cluster_name" {
  description = "Назва EKS кластера"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "API endpoint EKS кластера"
  value       = module.eks.cluster_endpoint
}

# Команда для налаштування kubectl
output "configure_kubectl" {
  description = "Команда для налаштування kubectl"
  value       = "aws eks update-kubeconfig --region eu-north-1 --name ${module.eks.cluster_name}"
}
