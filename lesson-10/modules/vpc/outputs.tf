# ===========================================
# Outputs VPC модуля
# ===========================================
#
# Ці значення використовуються іншими модулями (напр. RDS).

output "vpc_id" {
  description = "ID VPC для Security Group"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR блок VPC (використовується в allowed_cidr_blocks)"
  value       = aws_vpc.main.cidr_block
}

output "private_subnet_ids" {
  description = "Список ID приватних підмереж для DB Subnet Group"
  value       = aws_subnet.private[*].id
}

output "availability_zones" {
  description = "Список Availability Zones, де створено підмережі"
  value       = aws_subnet.private[*].availability_zone
}
