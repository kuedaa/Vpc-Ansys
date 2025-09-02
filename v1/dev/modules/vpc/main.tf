resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "VPC"
    Env = "${var.env}"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id     = aws_vpc.main.id
  tags = {
    Name = "IG"
    Env = "${var.env}"
  }
}

resource "aws_route_table" "public_route" {
  vpc_id     = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
tags = {
    Name = "Public_Route_Table"
    Env = "${var.env}"
  }
}