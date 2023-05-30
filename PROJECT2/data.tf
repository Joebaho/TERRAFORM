
# ZONE OF DATA SOURCE

# Data source getting the default VPC id
data "aws_vpc" "default" {
  default = true
}
# Declare the data source for AZ
data "aws_availability_zones" "available" {
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
#Data source getting the default subnets id
data "aws_subnets" "subnets" {
}

data "aws_subnet" "subnet" {
  for_each = toset(data.aws_subnets.subnets.ids)
  id       = each.value
}
# Find a certificate issued by (not imported into) ACM
# data "aws_acm_certificate" "amazon_issued" {
#   domain      = "*.joebahocloud.com"
#   types       = ["AMAZON_ISSUED"]
#   statuses    = ["ISSUED"]
#   most_recent = true
# }

