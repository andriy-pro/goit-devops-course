# Вихідні значення модуля ECR

output "repository_url" {
  description = "URL репозиторію для docker push/pull"
  value       = aws_ecr_repository.main.repository_url
}

output "repository_arn" {
  description = "ARN репозиторію"
  value       = aws_ecr_repository.main.arn
}

output "repository_name" {
  description = "Ім'я репозиторію"
  value       = aws_ecr_repository.main.name
}
