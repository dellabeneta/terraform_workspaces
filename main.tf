provider "aws" {
  region  = var.region
  profile = var.profile
}

locals {
  instance_types = {
    dev   = "t2.micro"
    stage = "t2.medium"
    prod  = "t3.medium"
  }
}

locals {
  instance_count = {
    dev   = "4"
    stage = "2"
    prod  = "2"
  }
}

resource "aws_key_pair" "key_pair" {
  public_key = file("~/.ssh/id_rsa.pub")
  key_name   = var.key_name
}

resource "aws_instance" "server" {
  ami                    = var.aws_ami
  subnet_id              = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name = var.key_name
  count                  = local.instance_count[terraform.workspace]
  instance_type          = local.instance_types[terraform.workspace]

  tags = {
    Name = "server-${terraform.workspace}"
  }
}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "vpc-${terraform.workspace}"
  }
}

resource "aws_subnet" "subnet" {
  cidr_block              = var.subnet_cidr
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-${terraform.workspace}"
  }
}

resource "aws_security_group" "sg" {
  name   = "sg"
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "sg-${terraform.workspace}"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
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

resource "aws_route_table_association" "table_association" {
    subnet_id = aws_subnet.subnet.id
    route_table_id = aws_route_table.route_table.id  
}

output "instances_public_ips" {
  value = aws_instance.server[*].public_ip
}