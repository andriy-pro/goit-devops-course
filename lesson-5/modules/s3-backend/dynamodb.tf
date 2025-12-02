# DynamoDB таблиця для блокування Terraform state
# Запобігає одночасним змінам інфраструктури кількома користувачами

resource "aws_dynamodb_table" "locks" {
  name = var.table_name

  # PAY_PER_REQUEST - платимо тільки за фактичні запити
  # (ідеально для невеликого навантаження)
  billing_mode = "PAY_PER_REQUEST"

  # LockID - обов'язковий ключ для Terraform state locking
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"  # S = String
  }

  tags = {
    Name    = var.table_name
    Purpose = "Terraform State Locking"
  }
}
