# modules/vpc/main.tf
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "vpc-${var.region}"
  }
}

# Internet Gateway para subnets públicas (DMZ)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "igw-${var.region}"
  }
}

# Elastic IP para o NAT Gateway
resource "aws_eip" "nat_eip" {

  tags = {
    Name = "nat-eip-${var.region}"
  }
}

# NAT Gateway (colocado na primeira subnet DMZ para ter acesso público)
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnets["DMZ-A"].id
  tags = {
    Name = "nat-${var.region}"
  }
}

# Subnets públicas (DMZ)
resource "aws_subnet" "public_subnets" {
  for_each = { for k, v in var.subnets : k => v if startswith(k, "DMZ") }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = element(var.availability_zones, index(keys(var.subnets), each.key) % length(var.availability_zones))
  tags = {
    Name = "subnet-${each.key}-${var.region}"
  }
}

# Subnets privadas (APP, BD, INFRA, LAMBDA, STAG)
resource "aws_subnet" "private_subnets" {
  for_each = { for k, v in var.subnets : k => v if !startswith(k, "DMZ") }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = element(var.availability_zones, index(keys(var.subnets), each.key) % length(var.availability_zones))
  tags = {
    Name = "subnet-${each.key}-${var.region}"
  }
}

# Tabela de rotas pública
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "rt-public-${var.region}"
  }
}

# Tabela de rotas privada
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "rt-private-${var.region}"
  }
}

# Associação das subnets públicas à tabela de rotas pública
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Associação das subnets privadas à tabela de rotas privada
resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}