# Основні ресурси VPC

# 1. VPC ("віртуальна приватна мережа")
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  # DNS підтримка - дозволяє використовувати DNS-імена всередині VPC
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.vpc_name
  }
}

# 2. Internet Gateway - з'єднує VPC з інтернетом
# Один IGW на VPC (безкоштовний)
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

# 3. Публічні підмережі (x3)
resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-public-${count.index + 1}"
    Type = "public"
    # Теги для EKS Load Balancer discovery: публічні ALB
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# 4. Приватні підмережі (x3)
resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = false

  tags = {
    Name = "${var.vpc_name}-private-${count.index + 1}"
    Type = "private"
    # Теги для EKS Load Balancer discovery: внутрішні NLB
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}