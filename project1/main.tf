#terraform Block 
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
}
# Define the vpc with the cidr
resource "aws_vpc" "project1_vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "project1_vpc"
  }
}
# public subnet 1
resource "aws_subnet" "project1_pub_subnet1" {
  vpc_id            = aws_vpc.project1_vpc.id
  cidr_block        = var.public_subnet1_cidr
  availability_zone = var.availability_zone["public_subnet1"] 
  tags = {
    Name = "project1_pub_subnet1"
  }
}
#public subnet2
resource "aws_subnet" "project1_pub_subnet2" {
  vpc_id            = aws_vpc.project1_vpc.id
  cidr_block        = var.public_subnet2_cidr
  availability_zone = var.availability_zone["public_subnet2"]
  tags = {
    Name = "project1_pub_subnet2"
  }
}
#private subnet1 
resource "aws_subnet" "project1_priv_subnet1" {
  vpc_id            = aws_vpc.project1_vpc.id
  cidr_block        = var.private_subnet1_cidr
  availability_zone = var.availability_zone["private_subnet1"]   
  tags = {
    Name = "project1_priv_subnet1"
  }
}
#private subnet2
resource "aws_subnet" "project1_priv_subnet2" {
  vpc_id            = aws_vpc.project1_vpc.id
  cidr_block        = var.private_subnet2_cidr
  availability_zone = var.availability_zone["private_subnet2"]
  tags = {
    Name = "project1_priv_subnet2"
  }
}
# Variable of vpc cidr block
variable "vpc_cidr" {
  description = "cidr block of our  project VPC"
  type        = string
}
# variable public subnet 1 cidr
variable "public_subnet1_cidr" {
  description = "cidr of the public subnet 1"
  type        = string
}
#variable public subnet 2 cidr
variable "public_subnet2_cidr" {
  description = "cidr of the public subnet 2"
  type        = string
}
#variable private subnet 1 cidr
variable "private_subnet1_cidr" {
  description = "cidr of the private subnet 1"
  type        = string
}
# variable private subnet 2 cidr
variable "private_subnet2_cidr" {
  description = "cidr of the private subnet 2"
  type        = string
}
# variable public cidr
variable "public_cidr" {
  description = "cidr of public access"
  type        = string
}
# variable az
variable "availability_zone" {
  description = "map of AZ"
  type        = map(string)
  default = {
    "public_subnet1"  = "us-west-2a"
    "public_subnet2"  = "us-west-2b"
    "private_subnet1" = "us-west-2a"
    "private_subnet2" = "us-west-2b"
  }
}
# Internet gateway
resource "aws_internet_gateway" "project1_igw" {
  vpc_id = aws_vpc.project1_vpc.id

  tags = {
    Name = "project1_igw"
  }
}
# public route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.project1_vpc.id
  route {
    cidr_block = var.public_cidr
    gateway_id = aws_internet_gateway.project1_igw.id
  }
  tags = {
    Name = "Public_RT"
  }
}
# Public subnet route table association
resource "aws_route_table_association" "public_subnet1" {
  subnet_id      = aws_subnet.project1_pub_subnet1.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "public_subnet2" {
  subnet_id      = aws_subnet.project1_pub_subnet2.id
  route_table_id = aws_route_table.public_rt.id
}
# NACL
resource "aws_network_acl" "project1_nacl" {
  vpc_id = aws_vpc.project1_vpc.id

  egress {
    protocol   = -1
    rule_no    = 200
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "Project1_Nacl"
  }
}
# NACL subnets association 
resource "aws_network_acl_association" "public_subnet1" {
  network_acl_id = aws_network_acl.project1_nacl.id
  subnet_id      = aws_subnet.project1_pub_subnet1.id
}
resource "aws_network_acl_association" "public_subnet2" {
  network_acl_id = aws_network_acl.project1_nacl.id
  subnet_id      = aws_subnet.project1_pub_subnet2.id
}
resource "aws_network_acl_association" "private_subnet1" {
  network_acl_id = aws_network_acl.project1_nacl.id
  subnet_id      = aws_subnet.project1_priv_subnet1.id
}
resource "aws_network_acl_association" "private_subnet2" {
  network_acl_id = aws_network_acl.project1_nacl.id
  subnet_id      = aws_subnet.project1_priv_subnet2.id
}

#Data source
data "aws_ami" "Linux_ami" {
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-2023.0.*.0-kernel-6.1-x86_64"]
  }
     # owners = ["546310954125"]

}  

# Create an EC2 instance
resource "aws_instance" "Linux_ec2" {
  instance_type          = var.instance_type
  ami                    = data.aws_ami.Linux_ami.id
  key_name               = var.key_name
  availability_zone      = var.availability_zone["public_subnet1"]
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  tags = {
    "Name" = "Linux_ec2"
  }
}
#Declaring instance_type variable
variable "instance_type" {
  description = "The type of the instance"
  type        = string
}
#Declaring key_name variable
variable "key_name" {
  description = "The key name use to launch the instance"
  type        = string
}
# create a security group
resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow ssh and http traffic"

  ingress {
    description = "SSH on the web server"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    description = "http on the web server"
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
    Name = "web_sg"
  }
}




