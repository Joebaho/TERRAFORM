# ZONE OF RESOURCES

#---------------------------------------------- Creation of the VPC--------------------------------------------
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  # instance_tenancy     = "default"
  enable_dns_hostnames = "true"
  tags = {
    Name = "VPC"
  }
}
#------------------------------------------- Create a Public Subnet 1-------------------------------------------
resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidrs[0]
  availability_zone       = data.aws_availability_zones.az.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "Public_Subnet1"
  }
}
#---------------------- Create a Public Subnet 2
resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidrs[1]
  availability_zone       = data.aws_availability_zones.az.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "Public_Subnet2"
  }
}
# Create a Public Subnet 3
resource "aws_subnet" "public_subnet3" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidrs[2]
  availability_zone       = data.aws_availability_zones.az.names[2]
  map_public_ip_on_launch = true
  tags = {
    Name = "Public_Subnet3"
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
# Public Subnet 3 Route table association
resource "aws_route_table_association" "assosubnet3" {
  subnet_id      = aws_subnet.public_subnet3.id
  route_table_id = aws_route_table.public_route.id
}
# Create a Private Subnet 1
resource "aws_subnet" "private_subnet1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_cidrs[0]
  availability_zone = data.aws_availability_zones.az.names[0]
  tags = {
    Name = "Private_Subnet1"
  }
}
# Create a Private Subnet 2
resource "aws_subnet" "private_subnet2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_cidrs[1]
  availability_zone = data.aws_availability_zones.az.names[1]
  tags = {
    Name = "Private_Subnet2"
  }
}
# Create a Private Subnet 3
resource "aws_subnet" "private_subnet3" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_cidrs[2]
  availability_zone = data.aws_availability_zones.az.names[2]
  tags = {
    Name = "Private_Subnet3"
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
    from_port  = var.port_number[2] #0
    to_port    = var.port_number[2] #0
  }
  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.public_cidr
    from_port  = var.port_number[2] #0
    to_port    = var.port_number[2] #0
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
resource "aws_network_acl_association" "public_subnet_association3" {
  subnet_id      = aws_subnet.public_subnet3.id
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
    from_port  = var.port_number[2] #0
    to_port    = var.port_number[2] #0
  }
  ingress {
    rule_no    = 200
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.public_cidr
    from_port  = var.port_number[2] #0
    to_port    = var.port_number[2] #0
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
resource "aws_network_acl_association" "private_subnet_association3" {
  subnet_id      = aws_subnet.private_subnet3.id
  network_acl_id = aws_network_acl.priv_nacl.id
}