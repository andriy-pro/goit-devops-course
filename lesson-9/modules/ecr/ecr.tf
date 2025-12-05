# ECR репозиторій для Docker образів

resource "aws_ecr_repository" "main" {
  name = var.ecr_name

  # MUTABLE - дозволяє перезаписувати теги (наприклад, latest)
  # IMMUTABLE - кожен тег унікальний (краще для production)
  image_tag_mutability = "MUTABLE"

  # Автоматичне сканування на вразливості безпеки
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  # Дозволяємо видалення репозиторію з образами
  # Тільки для навчальних цілей!
  force_delete = true

  tags = {
    Name = var.ecr_name
  }
}

# Lifecycle policy - автоматичне видалення старих образів
# Зберігаємо тільки останні 10 образів для економії місця
resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Зберігати тільки останні 10 образів"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
