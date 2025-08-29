resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block
  
  tags = {
    Name = "VPC"
    Env = "${var.env}"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.main.id
  count = var.number_subnet
  cidr_block = var.cidr_private_subnet[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "Private-Subnet-AZ${count.index}"
    Env = "${var.env}"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.main.id
  count = var.number_subnet
  cidr_block = var.cidr_public_subnet[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "Public-Subnet-AZ${count.index}"
    Env = "${var.env}"
  }
}