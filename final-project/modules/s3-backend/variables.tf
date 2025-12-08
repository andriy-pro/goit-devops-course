# Вхідні параметри модуля s3-backend

variable "bucket_name" {
  description = "Унікальне ім'я S3 bucket для зберігання Terraform state"
  type        = string
}

variable "table_name" {
  description = "Ім'я таблиці DynamoDB для блокування state"
  type        = string
}
