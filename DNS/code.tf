// This terraform code create: a VPC, 4 subnets ( 2 public subnets and 2 private subnets) with all the routes... 
// It also create an Ec2 with its security group in a public subnet...

// All the actual values of the declared variables in this code are located in the terraform.tfvars...

// In order to run this code, Type in your CMD line "terraform init", "terraform validate", "terraform plan" and then "terraform apply --auto-approve"

// Terraform required providers definition..
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

// variable declaration for the vpc aws region
variable "aws_region" {
  type    = string
}

// Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

// variable declarations for the public_cidr and the vpc_cidr
variable "public_cidr" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

// VPC creation section
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"
  tags = {
    Name = "VPC"
  }
}


// Internet gateway creation
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "IGW"
  }
}


// Create a Route Table and associate it with the VPC
resource "aws_route_table" "publicroute" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = var.public_cidr
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "PublicRoute"
  }
}


# Declare the data source for AZ
data "aws_availability_zones" "az" {
  state = "available"
}

// variable declarations for the public_subnet_cidrs
variable "public_subnet_cidrs" {
  type    = list(string)
}

// Create a Public Subnet 1
resource "aws_subnet" "publicsubnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidrs[0]
  availability_zone       = data.aws_availability_zones.az.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet1"
  }
}
// Public Subnet 1 Route table association
resource "aws_route_table_association" "assosubnet1" {
  subnet_id      = aws_subnet.publicsubnet1.id
  route_table_id = aws_route_table.publicroute.id
}

// Create a Public Subnet 2
resource "aws_subnet" "publicsubnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidrs[1]
  availability_zone       = data.aws_availability_zones.az.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet2"
  }
}
// Public Subnet 2 Route table association
resource "aws_route_table_association" "assosubnet2" {
  subnet_id      = aws_subnet.publicsubnet2.id
  route_table_id = aws_route_table.publicroute.id
}

// variable declarations for the private_subnet_cidrs
variable "private_subnet_cidrs" {
  type    = list(string)
}

// Create a Private Subnet 1
resource "aws_subnet" "privatesubnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet_cidrs[0]
  availability_zone       = data.aws_availability_zones.az.names[0]
  map_public_ip_on_launch = false
  tags = {
    Name = "PrivateSubnet1"
  }
}

// Create a Private Subnet 2
resource "aws_subnet" "privatesubnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet_cidrs[1]
  availability_zone       = data.aws_availability_zones.az.names[1]
  map_public_ip_on_launch = false
  tags = {
    Name = "PrivateSubnet2"
  }
}


// variable declarations for the ec2 public security group
resource "aws_security_group" "publicsg" {
  name = "PublicSG"
  description = "Public Security Group"
  vpc_id = aws_vpc.vpc.id
  ingress {
    description = "SSH from everywhere"
    cidr_blocks = [var.public_cidr]
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }
  ingress {
    description = "HTTP from everywhere"
    cidr_blocks = [var.public_cidr]
    from_port = 80
    to_port = 80
    protocol = "tcp"
  }
  ingress {
    description = "HTTPS from everywhere"
    cidr_blocks = [var.public_cidr]
    from_port = 443
    to_port = 443
    protocol = "tcp"
  }
  egress {
    cidr_blocks = [var.public_cidr]
    from_port = 0
    to_port = 0
    protocol = "-1"
  }
  tags = {
    "Name" = "PublicSG"
  }
}


// variable declaration for the NACL
resource "aws_network_acl" "nacl" {
  vpc_id = aws_vpc.vpc.id

  egress {
    rule_no = 100
    protocol    = "tcp"
    action      = "allow"
    cidr_block  = var.public_cidr
    from_port   = 0
    to_port     = 0
  }
  ingress {
    rule_no = 100
    protocol    = "tcp"
    action      = "allow"
    cidr_block  = var.public_cidr
    from_port   = 0
    to_port     = 0
  }
  tags = {
    "Name" = "My_OPEN_NACL"
  }
}
// NACL associations
resource "aws_network_acl_association" "public_subnet_association1" {
  subnet_id          = aws_subnet.publicsubnet1.id
    network_acl_id     = aws_network_acl.nacl.id
}
resource "aws_network_acl_association" "public_subnet_association2" {
  subnet_id          = aws_subnet.publicsubnet2.id
    network_acl_id     = aws_network_acl.nacl.id
}
resource "aws_network_acl_association" "private_subnet_association1" {
  subnet_id          = aws_subnet.privatesubnet1.id
  network_acl_id     = aws_network_acl.nacl.id
}
resource "aws_network_acl_association" "private_subnet_association2" {
  subnet_id          = aws_subnet.privatesubnet2.id
  network_acl_id     = aws_network_acl.nacl.id
}


// Declare the data source for the latest AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

// variable declarations for the instance type
variable "instance_type" {
 type = string
 description = "EC2 instance type"
}

// variable declarations for the piublic key location
variable "my_keypair_name" {
 type = string
 description = "Key Pair Name"
}
variable "public_key_location" {
 type = string
 description = "Public Key Location variable"
}
resource "aws_key_pair" "ssh-key" {
  key_name = var.my_keypair_name
  public_key = file(var.public_key_location)
}


// EC2 creation
resource "aws_instance" "myec2" {
    ami = data.aws_ami.amazon_linux_2.id
    instance_type = var.instance_type
    subnet_id = aws_subnet.publicsubnet1.id 
    vpc_security_group_ids = [aws_security_group.publicsg.id]
    key_name = aws_key_pair.ssh-key.key_name
    associate_public_ip_address = "true"
    tags = {
    Name = "My-EC2"
  }
}