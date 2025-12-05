# Вихідні значення модуля VPC

output "vpc_id" {
  description = "ID створеного VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR блок VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "Список ID публічних підмереж"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Список ID приватних підмереж"
  value       = aws_subnet.private[*].id
}

output "internet_gateway_id" {
  description = "ID Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_id" {
  description = "ID NAT Gateway"
  value       = aws_nat_gateway.main.id
}
