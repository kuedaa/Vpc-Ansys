output "vpc_id" {
  description = "VPC id."
  value = aws_vpc.main.id
}

output "vpc_cidr_block" {
  value = aws_vpc.main.cidr_block
}

output "igw_id" {
  value = aws_internet_gateway.gw.id
}

output "public_route_table_id" {
  value = aws_route_table.public_route.id
}