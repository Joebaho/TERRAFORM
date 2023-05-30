# ZONE OF LOAD BALANCER

# --------------------------------Create a new load balancer-----------------------------------------------------
resource "aws_lb" "as_alb" {
  name                       = "as-alb"
  subnets                    = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id, aws_subnet.public_subnet3.id]
  internal                   = false
  load_balancer_type         = "application"
  enable_deletion_protection = false
  security_groups            = [aws_security_group.alb_sg.id]
  tags = {
    Name = "as-alb"
  }
}
#----------------------------------------http listener of the load balancer----------------------------------------
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.as_alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.alb_tg.id
    type             = "forward"
  }
}
#----------------------------------------https listener on the load balancer---------------------------------------
# resource "aws_lb_listener" "https_listener" {
#   load_balancer_arn = aws_lb.as_alb.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = data.aws_acm_certificate.amazon_issued.arn

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.alb_tg.arn
#   }
# }
#-------------------------------------------creation target group for the ALB-----------------------------------------
resource "aws_lb_target_group" "alb_tg" {
  load_balancing_cross_zone_enabled = true
  name                              = "alb-tg"
  target_type                       = "instance"
  port                              = var.port_number[0]
  protocol                          = "HTTP"
  vpc_id                            = aws_vpc.vpc.id
  protocol_version                  = "HTTP1"
  health_check {
    # healthy_threshold   = 5
    unhealthy_threshold = 3
    timeout             = 5
    path                = "/"
    interval            = 30
  }
  tags = {
    Name = "alb_tg"
  }
}
#-----------------------------------------target group association--------------------------------------------------
resource "aws_lb_target_group_attachment" "server_alb_tg" {
  target_group_arn = aws_lb_target_group.alb_tg.arn
  target_id        = aws_autoscaling_group.as_group.id
  port             = 80

}
# resource "aws_lb_target_group_attachment" "server_alb_tg2" {
#   target_group_arn = aws_lb_target_group.alb_tg.arn
#   target_id        = aws_instance.server[1].id
#   port             = 80
# }
#---------------------------------------- Declaration of the alb security group---------------------------------------
resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "alb Security Group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "HTTP from everywhere"
    from_port   = var.port_number[0] #80
    to_port     = var.port_number[0] #80
    protocol    = "tcp"
    cidr_blocks = [var.public_cidr]
  }
  ingress {
    description = "HTTPS from everywhere"
    from_port   = var.port_number[1] #443
    to_port     = var.port_number[1] #443
    protocol    = "tcp"
    cidr_blocks = [var.public_cidr]
  }
  egress {
    cidr_blocks = [var.public_cidr]
    from_port   = var.port_number[2] #0
    to_port     = var.port_number[2] #0
    protocol    = "-1"
  }
  tags = {
    "Name" = "alb_SG"
  }
}
#--------------------------------------------Declaration of the ec2 security group------------------------------------
resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Public Security Group"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    description     = "HTTP from everywhere"
    security_groups = [aws_security_group.alb_sg.id]
    from_port       = var.port_number[0] #80
    to_port         = var.port_number[0] #80
    protocol        = "tcp"
  }
  ingress {
    description     = "HTTPS from everywhere"
    security_groups = [aws_security_group.alb_sg.id]
    from_port       = var.port_number[1] #443
    to_port         = var.port_number[1] #443
    protocol        = "tcp"
  }
  egress {
    cidr_blocks = [var.public_cidr]
    from_port   = var.port_number[2] #0
    to_port     = var.port_number[2] #0
    protocol    = "-1"
  }
  tags = {
    "Name" = "Web_SG"
  }
}