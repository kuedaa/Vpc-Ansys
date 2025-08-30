resource "aws_subnet" "private_subnet" {
  vpc_id     = data.terraform_remote_state.vpc.outputs.vpc_id
  count = var.number_subnet
  cidr_block = var.cidr_private_subnet[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "Private-Subnet-AZ${count.index}"
    Env = "${var.env}"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = data.terraform_remote_state.vpc.outputs.vpc_id
  count = var.number_subnet
  cidr_block = var.cidr_public_subnet[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "Public-Subnet-AZ${count.index}"
    Env = "${var.env}"
  }
}

