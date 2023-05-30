#--------------------------------------- ZONE OF DATA SOURCE-----------------------------------------------------

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


#------------------------------------------- ZONE OF RESOURCES----------------------------------------------------

# Create an EC2 instance
resource "aws_instance" "server" {
  count                       = 3
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.instance_type[data.aws_availability_zones.available.names[count.index]]
  availability_zone           = data.aws_availability_zones.available.names[count.index]
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = "true"

  user_data = <<-EOF
  #!/bin/bash
  yum update -y
  yum install -y httpd.x86_64
  systemctl start httpd.service
  systemctl enable httpd.service
  echo "WELCOME TO TERRAFORM CLASS
   You successfully access Joseph Mbatchou web page launched via Terraform code.
    Welcome here and we hope you will enjoy coding with Terraform!" > /var/www/html/index.html
  EOF   
  tags = {
    Name = "server-${count.index + 1}"
  }
}
# Create a new load balancer
resource "aws_lb" "my_alb" {
  count                      = length(aws_instance.server[*].id) >= 2 ? 1 : 0
  name                       = "my-alb"
  subnets                    = [for subnet in data.aws_subnet.subnet : subnet.id]
  internal                   = false
  load_balancer_type         = "application"
  enable_deletion_protection = false
  security_groups            = [aws_security_group.alb_sg.id]
  tags = {
    Name = "my-alb"
  }
}
#http listener of the load balancer
resource "aws_lb_listener" "http_listener" {
  # count             = 1
  load_balancer_arn = aws_lb.my_alb[0].arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.alb_tg.arn
    type             = "forward"
  }
}
#https listener on the load balancer
# resource "aws_lb_listener" "https_listener" {
#   # count             = 1
#   load_balancer_arn = aws_lb.my_alb[0].arn
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = data.aws_acm_certificate.amazon_issued.arn

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.alb_tg.arn
#   }
# }
#creation target group for the ALB
resource "aws_lb_target_group" "alb_tg" {
  # load_balancing_cross_zone_enabled = true
  name = "alb-tg"
  # target_type                       = "instance"
  depends_on       = [aws_instance.server]
  port             = 80
  protocol         = "HTTP"
  vpc_id           = data.aws_vpc.default.id
  protocol_version = "HTTP1"
  health_check {
    # healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    path                = "/"
    interval            = 20
  }
  tags = {
    Name = "alb_tg"
  }
}
#target group association
# resource "aws_lb_target_group_attachment" "server_alb_tg1" {
#   target_group_arn = aws_lb_target_group.alb_tg.arn
#   target_id        = aws_instance.server[1].id
#   port             = 80
# }
# resource "aws_lb_target_group_attachment" "server_alb_tg2" {
#   target_group_arn = aws_lb_target_group.alb_tg.arn
#   target_id        = aws_instance.server[2].id
#   port             = 80
# }
resource "aws_lb_target_group_attachment" "server_alb_tg" {
  count            = 2
  target_group_arn = aws_lb_target_group.alb_tg.arn
  target_id        = aws_instance.server[count.index].id
  port             = 80
}
# ec2 SG
resource "aws_security_group" "web_sg" {
  vpc_id      = data.aws_vpc.default.id
  description = "security group for server"
  name        = "web_sg"

  ingress {
    from_port       = var.port_number[0] #80
    to_port         = var.port_number[0] #80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  ingress {
    from_port       = var.port_number[1] #443
    to_port         = var.port_number[1] #443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  egress {
    from_port   = var.port_number[2] #0
    to_port     = var.port_number[2] #0
    protocol    = "-1"
    cidr_blocks = [var.public_cidr]
  }
  tags = {
    "Name" = "web_sg"
  }
}
# Declaration of the alb security group
resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "alb Security Group"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP from everywhere"
    cidr_blocks = [var.public_cidr]
    from_port   = var.port_number[0] #80
    to_port     = var.port_number[0] #80
    protocol    = "tcp"
  }
  ingress {
    description = "HTTPS from everywhere"
    cidr_blocks = [var.public_cidr]
    from_port   = var.port_number[1] #443
    to_port     = var.port_number[1] #443
    protocol    = "tcp"

  }
  egress {
    cidr_blocks = [var.public_cidr]
    from_port   = var.port_number[2] #0
    to_port     = var.port_number[2] #0
    protocol    = "-1"
  }
  tags = {
    "Name" = "alb_sg"
  }
}














