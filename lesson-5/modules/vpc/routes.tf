# Маршрутизація трафіку в VPC

# 1. Elastic IP для NAT Gateway
# NAT Gateway потребує статичну публічну IP-адресу
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.vpc_name}-nat-eip"
  }

  # Спочатку має існувати Internet Gateway
  depends_on = [aws_internet_gateway.main]
}

# 2. NAT Gateway
# Дозволяє ресурсам у приватних підмережах виходити в інтернет
# УВАГА: платний ресурс (~$0.045/год)!
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id

  # NAT Gateway розміщується в публічній підмережі
  subnet_id = aws_subnet.public[0].id

  tags = {
    Name = "${var.vpc_name}-nat"
  }

  depends_on = [aws_internet_gateway.main]
}

# 3. Route Table для публічних підмереж
# Весь трафік (0.0.0.0/0) йде через Internet Gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

# 4. Route Table для приватних підмереж
# Весь трафік (0.0.0.0/0) йде через NAT Gateway
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.vpc_name}-private-rt"
  }
}

# 5. Прив'язка Route Table до публічних підмереж
resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# 6. Прив'язка Route Table до приватних підмереж
resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
