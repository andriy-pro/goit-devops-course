# Вихідні значення модуля s3-backend
# (можна використовувати в інших частинах конфігурації)

output "bucket_name" {
  description = "Ім'я створеного S3 bucket"
  value       = aws_s3_bucket.state.bucket
}

output "bucket_arn" {
  description = "ARN (Amazon Resource Name) S3 bucket"
  value       = aws_s3_bucket.state.arn
}

output "dynamodb_table_name" {
  description = "Ім'я DynamoDB таблиці для блокувань"
  value       = aws_dynamodb_table.locks.name
}
