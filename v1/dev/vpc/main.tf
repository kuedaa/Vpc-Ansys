resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block
  
  tags = {
    Name = "VPC"
    Env = "${var.env}"
  }
}

