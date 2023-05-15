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

# Create an EC2 instance
resource "aws_instance" "my_ec2" {
  instance_type = "t3.micro"
  ami = "ami-009c5f630e96948cb"
  key_name ="Oregon-Key-Pair" 
  tags = {
    "Name" = "my_ec2"
  }
}