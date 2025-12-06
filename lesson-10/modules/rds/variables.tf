# ===========================================
# Основні змінні модуля
# ===========================================
#
# Ці змінні визначають тип та конфігурацію бази даних.

variable "use_aurora" {
  description = "Використовувати Aurora Cluster замість звичайного RDS Instance. true = Aurora, false = RDS"
  type        = bool
  default     = false
}

variable "identifier" {
  description = "Унікальний ідентифікатор бази даних в AWS. Використовується в назвах всіх ресурсів."
  type        = string
}

variable "engine" {
  description = "Engine бази даних. Для RDS: postgres, mysql, mariadb. Для Aurora: aurora-postgresql, aurora-mysql"
  type        = string
  default     = "postgres"

  validation {
    condition = contains([
      "postgres", "mysql", "mariadb",
      "aurora-postgresql", "aurora-mysql"
    ], var.engine)
    error_message = "Engine має бути одним з: postgres, mysql, mariadb, aurora-postgresql, aurora-mysql"
  }
}

variable "engine_version" {
  description = "Версія engine. Приклади: 15.4 для PostgreSQL, 8.0.35 для MySQL"
  type        = string
  default     = "15.4"
}

variable "instance_class" {
  description = "Клас інстансу. db.t3.micro для dev/test, db.r6g.large для prod. Для Aurora мінімум db.t3.medium"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Початковий розмір сховища в GB. Тільки для RDS (Aurora масштабується автоматично)"
  type        = number
  default     = 20
}

variable "multi_az" {
  description = "Увімкнути Multi-AZ для високої доступності. true = standby в іншій AZ (дорожче)"
  type        = bool
  default     = false
}

# ===========================================
# Параметри бази даних
# ===========================================
#
# Credentials та назва бази даних для створення.

variable "db_name" {
  description = "Назва бази даних, яка буде створена автоматично"
  type        = string
}

variable "db_username" {
  description = "Master username для підключення до бази даних"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Master password. Якщо не задано - генерується автоматично (рекомендовано)"
  type        = string
  default     = null
  sensitive   = true # не показувати в логах
}

# ===========================================
# Мережеві параметри
# ===========================================
#
# VPC та підмережі, де буде розміщена БД.

variable "vpc_id" {
  description = "ID VPC, в якому буде створено Security Group"
  type        = string
}

variable "subnet_ids" {
  description = "Список ID приватних підмереж для DB Subnet Group. Мінімум 2 в різних AZ для Multi-AZ"
  type        = list(string)
}

variable "allowed_security_groups" {
  description = "Список Security Group IDs, яким дозволено доступ до БД (напр. SG вашого додатку)"
  type        = list(string)
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "Список CIDR блоків, яким дозволено доступ до БД (напр. VPC CIDR: 10.0.0.0/16)"
  type        = list(string)
  default     = []
}

# ===========================================
# Parameter Group налаштування
# ===========================================
#
# Ці параметри налаштовують поведінку бази даних.
# Значення за замовчуванням підходять для dev/test.

variable "max_connections" {
  description = "Максимальна кількість одночасних з'єднань до БД. Залежить від RAM інстансу"
  type        = number
  default     = 100
}

variable "log_statement" {
  description = "Рівень логування SQL запитів (тільки PostgreSQL). none=вимкнено, ddl=DDL, mod=зміни даних, all=всі запити"
  type        = string
  default     = "none"

  validation {
    condition     = contains(["none", "ddl", "mod", "all"], var.log_statement)
    error_message = "log_statement має бути одним з: none, ddl, mod, all"
  }
}

variable "work_mem" {
  description = "Пам'ять для операцій сортування в KB (тільки PostgreSQL). За замовчуванням 4MB"
  type        = number
  default     = 4096 # 4MB
}

# ===========================================
# Backup та maintenance
# ===========================================
#
# Налаштування резервного копіювання та захисту.

variable "backup_retention_period" {
  description = "Кількість днів зберігання автоматичних бекапів. 0 = бекапи вимкнені"
  type        = number
  default     = 7
}

variable "skip_final_snapshot" {
  description = "Пропустити створення фінального snapshot при видаленні БД. true для dev/test, false для prod"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Захист від випадкового видалення через консоль/API. true для prod, false для dev/test"
  type        = bool
  default     = false
}

# ===========================================
# Теги
# ===========================================

variable "tags" {
  description = "Теги, які будуть додані до всіх ресурсів модуля"
  type        = map(string)
  default     = {}
}
