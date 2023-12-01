


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-northeast-1"

}






resource "aws_vpc" "vpc" {
  cidr_block = "10.99.0.0/16"
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.99.0.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "route_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_instance" "poc_instance" {
  ami             = "ami-09a81b370b76de6a2" #Ubuntu (intel)
  instance_type   = "t3.nano"
  subnet_id       = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.poc_instance_sg.id]
  key_name        = "radio"
  tags = {
    Name = "PocEC2Instance"
  }
}


resource "aws_security_group" "poc_instance_sg" {
  name   = "ec2-sg"
  vpc_id = aws_vpc.vpc.id

}



resource "aws_security_group_rule" "in_ssh" {
  type              = "ingress"
  from_port         = 0
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.poc_instance_sg.id
}

resource "aws_security_group_rule" "out_ip_any" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.poc_instance_sg.id
}


output "server_public_ip" {
  description = "The public IP address assigned to the instanceue"
  value       = aws_instance.poc_instance.public_ip
}