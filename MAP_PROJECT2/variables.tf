# ZONE OF ALL VARIABLES USE IN THIS CODE

# variable declaration for the vpc aws region
variable "aws_region" {
  type = string
}
# variable declarations for the instance type
variable "instance_type" {
  type        = map(string)
  description = "EC2 instance type"
  default = {
    "us-west-2a" = "t2.micro"
    "us-west-2b" = "t2.nano"
    "us-west-2c" = "t2.small"
  }
}
# variable declarations for the public key location
variable "key_name" {
  type        = string
  description = "Key Pair Name"
}
# variable declarations for port
variable "port_number" {
  type        = list(number)
  description = "list of port number for security group ingress and egress rules"
}
# variable declarations for the public_cidr
variable "public_cidr" {
  type = string
}
# variable declarations for the vpc_cidr
variable "vpc_cidr" {
  type = string
}
#list of subnet Id 
variable "subnet_id" {
  type        = list(string)
  description = "list of subnet id."
}


