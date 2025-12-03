# Вхідні параметри модуля VPC

variable "vpc_name" {
  description = "Ім'я VPC (використовується в тегах)"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR блок для VPC (діапазон IP-адрес)"
  type        = string
}

variable "availability_zones" {
  description = "Список Availability Zones для розміщення підмереж"
  type        = list(string)
}

variable "public_subnets" {
  description = "CIDR блоки для публічних підмереж"
  type        = list(string)
}

variable "private_subnets" {
  description = "CIDR блоки для приватних підмереж"
  type        = list(string)
}

variable "cluster_name" {
  description = "Назва кластера EKS для тегування підмереж"
  type        = string
  default     = ""
}