resource "aws_subnet" "private_subnet" {
  vpc_id     = var.vpc_id
  count = var.number_subnet
  cidr_block = var.cidr_private_subnet[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "Private-Subnet-AZ${count.index}"
    Env = "${var.env}"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = var.vpc_id  
  count = var.number_subnet
  cidr_block = var.cidr_public_subnet[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-Subnet-AZ${count.index}"
    Env = "${var.env}"
  }
}

resource "aws_eip" "eip" {
  count = var.number_subnet
  domain   = "vpc"
  tags = {
    Name = "eip-AZ${count.index}"
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
}

resource "aws_route_table" "public" {
  vpc_id     = var.vpc_id 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }
  tags = {
    Name = "Main-Route-Table"
    Env = "${var.env}"
  }
}

resource "aws_route_table_association" "public_assoc" {
  count = var.number_subnet
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count = var.number_subnet
  vpc_id     = var.vpc_id 
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway[count.index].id
  }
tags = {
    Name = "private-rt-${count.index}"
    Env = "${var.env}"
  }
}

resource "aws_route_table_association" "private_assoc" {
  count = var.number_subnet
  subnet_id = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}


resource "aws_security_group" "http_sg" {
  name        = "http-security-group"
  description = "Security group allowing HTTP traffic on port 80"
  vpc_id     = var.vpc_id 

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