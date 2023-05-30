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
# Find a certificate issued by AMAZON
# data "aws_acm_certificate" "amazon_issued" {
#   domain      = "joebahocloud.com"
#   types       = ["AMAZON_ISSUED"]
#   statuses    = ["ISSUED"]
#   most_recent = true
# }