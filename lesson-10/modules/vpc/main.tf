# ===========================================
# Мінімальний VPC для тестування RDS
# ===========================================
#
# Цей модуль створює спрощений VPC тільки з приватними підмережами.
# Без NAT Gateway (RDS не потребує доступу до інтернету).
# Використовується виключно для демонстрації роботи RDS модуля.

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true # потрібно для RDS endpoints
  enable_dns_support   = true # потрібно для DNS resolution

  tags = merge(var.tags, {
    Name = var.vpc_name
  })
}

# ===========================================
# Приватні підмережі
# ===========================================
#
# Для RDS Multi-AZ потрібно мінімум 2 підмережі в різних Availability Zones.
# Підмережі створюються динамічно на основі списку AZ.
#
# cidrsubnet(var.vpc_cidr, 8, count.index):
# - var.vpc_cidr = "10.0.0.0/16"
# - 8 = додаємо 8 біт до маски (16 + 8 = 24)
# - count.index = порядковий номер підмережі
# Результат:
# - index 0: 10.0.0.0/24
# - index 1: 10.0.1.0/24

resource "aws_subnet" "private" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-private-${count.index + 1}"
    Type = "private"
  })
}
