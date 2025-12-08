# S3 Bucket для зберігання Terraform State

resource "aws_s3_bucket" "state" {
  bucket = var.bucket_name

  # Дозволяємо видалення bucket навіть якщо він не порожній
  # Використовуємо тільки для навчальних цілей!
  force_destroy = true

  tags = {
    Name    = var.bucket_name
    Purpose = "Terraform State Storage"
  }
}

# Версіонування - зберігає історію змін state файлу
# (дозволяє відновити попередню версію якщо "щось пішло не так")
resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Шифрування - State може містити чутливу інформацію (паролі, ключі)
resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Блокування публічного доступу - критично для безпеки!
# (State-файл ніколи не повинен бути публічним)
resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
