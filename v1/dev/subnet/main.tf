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

resource "aws_internet_gateway" "gw" {
  vpc_id     = data.terraform_remote_state.vpc.outputs.vpc_id
  tags = {
    Name = "IG"
    Env = "${var.env}"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  count = var.number_subnet
  subnet_id = aws_subnet.public_subnet[count.index].id
  allocation_id = aws_eip.eip[count.index].id
  tags = {
    Name = "Nat_gateway-AZ${count.index}"
    Env = "${var.env}"
  }
  depends_on = [aws_internet_gateway.gw]
}
# EIP for NAT Gateway in AZ A
resource "aws_eip" "eip" {
  count = var.number_subnet
  domain   = "vpc"
  tags = {
    Name = "eip-AZ${count.index}"
    Env = "${var.env}"
  }
}


resource "aws_security_group" "http_sg" {
  name        = "http-security-group"
  description = "Security group allowing HTTP traffic on port 80"
  vpc_id     = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  tags = {
    Name = "HTTP-Security-Group"
    Env = "${var.env}"
  }
}


resource "aws_instance" "web" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private_subnet[0].id
  vpc_security_group_ids = [aws_security_group.http_sg.id]
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install nginx1 -y
              systemctl enable nginx
              systemctl start nginx
              echo "<h1>Hello from Terraform + Nginx</h1>" > /usr/share/nginx/html/index.html
              EOF

  tags = {
    Name = "nginx-server"
    Env = "${var.env}"
  }
}