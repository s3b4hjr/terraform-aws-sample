# modules/vpc/outputs.tf
output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = { for k, v in aws_subnet.public_subnets : k => v.id }
}

output "private_subnet_ids" {
  value = { for k, v in aws_subnet.private_subnets : k => v.id }
}

output "igw_id" {
  value = aws_internet_gateway.igw.id
}

output "nat_gw_id" {
  value = aws_nat_gateway.nat.id
}