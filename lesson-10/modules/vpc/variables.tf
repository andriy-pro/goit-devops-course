# ===========================================
# Змінні VPC модуля
# ===========================================

variable "vpc_name" {
  description = "Назва VPC, використовується в тегах"
  type        = string
  default     = "lesson-10-vpc"
}

variable "vpc_cidr" {
  description = "CIDR блок для VPC. /16 дає 65536 IP адрес"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Список Availability Zones для приватних підмереж. Мінімум 2 для Multi-AZ"
  type        = list(string)
  default     = ["eu-north-1a", "eu-north-1b"]
}

variable "tags" {
  description = "Теги для всіх ресурсів"
  type        = map(string)
  default     = {}
}
