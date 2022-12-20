variable "profile" {
  default = "michel.dellabeneta"
}

variable "region" {
  default = "us-east-1"
}

variable "aws_ami" {
  default = "ami-09d3b3274b6c5d4aa"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "key_name" {
  default = "key_name"
}