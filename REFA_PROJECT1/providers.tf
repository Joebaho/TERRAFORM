# This terraform code create: a VPC, 4 subnets ( 2 public subnets and 2 private subnets) with all the routes... 
# It also create an Ec2 with its security group in a public subnet...
# All the actual values of the declared variables in this code are located in the terraform.tfvars...

# Terraform required providers definition..
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
#Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}