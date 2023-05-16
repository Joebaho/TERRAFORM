# ZONE OF DATA SOURCE

# Declare the data source for AZ
data "aws_availability_zones" "az" {
  state = "available"
}
# Declare the data source for the latest AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ZONE OF RESOURCES

# Creation of the VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"
  tags = {
    Name = "VPC"
  }
}
# Create a Public Subnet 1
resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidrs[0]
  availability_zone       = data.aws_availability_zones.az.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "Public_Subnet1"
  }
}
# Create a Public Subnet 2
resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidrs[1]
  availability_zone       = data.aws_availability_zones.az.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "Public_Subnet2"
  }
}
# Internet gateway creation
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "IGW"
  }
}
# Create a Route Table and associate it with the VPC
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = var.public_cidr
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "Public_Route"
  }
}
# Public Subnet 1 Route table association
resource "aws_route_table_association" "assosubnet1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_route.id
}
# Public Subnet 2 Route table association
resource "aws_route_table_association" "assosubnet2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_route.id
}
# Create a Private Subnet 1
resource "aws_subnet" "private_subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet_cidrs[0]
  availability_zone       = data.aws_availability_zones.az.names[0]
  map_public_ip_on_launch = false
  tags = {
    Name = "Private_Subnet1"
  }
}
# Create a Private Subnet 2
resource "aws_subnet" "private_subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet_cidrs[1]
  availability_zone       = data.aws_availability_zones.az.names[1]
  map_public_ip_on_launch = false
  tags = {
    Name = "Private_Subnet2"
  }
}
# Creation for the public NACL
resource "aws_network_acl" "pub_nacl" {
  vpc_id = aws_vpc.vpc.id

  egress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.public_cidr
    from_port  = var.port_number[3]   #0
    to_port    = var.port_number[3]   #0
  }
  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.public_cidr
    from_port  = var.port_number[3]  #0
    to_port    = var.port_number[3] #0
  }
  tags = {
    "Name" = "Pub_Nacl"
  }
}
# Public NACL associations
resource "aws_network_acl_association" "public_subnet_association1" {
  subnet_id      = aws_subnet.public_subnet1.id
  network_acl_id = aws_network_acl.pub_nacl.id
}
resource "aws_network_acl_association" "public_subnet_association2" {
  subnet_id      = aws_subnet.public_subnet2.id
  network_acl_id = aws_network_acl.pub_nacl.id
}
# Creation for the Private NACL
resource "aws_network_acl" "priv_nacl" {
  vpc_id = aws_vpc.vpc.id

  egress {
    rule_no    = 200
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.public_cidr
    from_port  = var.port_number[3]  #0
    to_port    = var.port_number[3]  #0
  }
  ingress {
    rule_no    = 200
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.public_cidr
    from_port  = var.port_number[3] #0
    to_port    = var.port_number[3] #0
  }
  tags = {
    "Name" = "Priv_NACL"
  }
}
# Private NACL associations
resource "aws_network_acl_association" "private_subnet_association1" {
  subnet_id      = aws_subnet.private_subnet1.id
  network_acl_id = aws_network_acl.priv_nacl.id
}
resource "aws_network_acl_association" "private_subnet_association2" {
  subnet_id      = aws_subnet.private_subnet2.id
  network_acl_id = aws_network_acl.priv_nacl.id
}
# Declaration of the ec2 security group
resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Public Security Group"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    description = "SSH from everywhere"
    cidr_blocks = [var.public_cidr]
    from_port   = var.port_number[0] #22
    to_port     = var.port_number[0] #22
    protocol    = "tcp"
  }
  ingress {
    description = "HTTP from everywhere"
    cidr_blocks = [var.public_cidr]
    from_port   = var.port_number[1] #80
    to_port     = var.port_number[1] #80
    protocol    = "tcp"
  }
  ingress {
    description = "HTTPS from everywhere"
    cidr_blocks = [var.public_cidr]
    from_port   = var.port_number[2] #443
    to_port     = var.port_number[2] #443
    protocol    = "tcp"
  }
  egress {
    cidr_blocks = [var.public_cidr]
    from_port   = var.port_number[3]  #0
    to_port     = var.port_number[3]  #0
    protocol    = "-1"
  }
  tags = {
    "Name" = "Web_SG"
  }
}
# EC2_1 creation
resource "aws_instance" "my_ec2" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet1.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = "true"
  tags = {
    Name = "My-EC2"
  }
}




