output "cluster_endpoint" {
  description = "Endpoint EKS кластера (URL для API)"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_name" {
  description = "Назва EKS кластера"
  value       = aws_eks_cluster.main.name
}

output "cluster_certificate_authority" {
  description = "CA сертифікат EKS кластера (base64)"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "ID Security Group для EKS кластера"
  value       = aws_security_group.eks_cluster.id
}
