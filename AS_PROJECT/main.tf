# ZONE OF DATA SOURCE

#---------------------------Declare the data source for AZ-----------------------------------------
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
# --------------------------Find a certificate issued by (not imported into) ACM-----------------------
# data "aws_acm_certificate" "amazon_issued" {
#   domain      = "joebahocloud.com"
#   types       = ["AMAZON_ISSUED"]
#   statuses    = ["ISSUED"]
#   most_recent = true
# }


#-----------------------------------Creation of the launch template-------------------------------
resource "aws_launch_template" "as_template" {
  name_prefix            = "as-launch-template"
  image_id               = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  # user_data              = <<-EOF
  # #!/bin/bash
  # yum update -y
  # yum install -y httpd.x86_64
  # systemctl start httpd.service
  # systemctl enable httpd.service
  # echo "WELCOME TO TERRAFORM CLASS
  #  You successfully access Joseph Mbatchou web page launched via Terraform code.
  #   Welcome here and we hope you will enjoy coding with Terraform!" > /var/www/html/index.html
  # EOF 
  tags = {
    Name = "as_template"
  }
}
#-------------------------Creation of the autoscaling group------------------------
resource "aws_autoscaling_group" "as_group" {
  # availability_zones = data.aws_availability_zones.az.names #["us-west-2a", "us-west-2b","us-west-2c"]
  desired_capacity   = 3
  max_size           = 4
  min_size           = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  launch_template {
    id      = aws_launch_template.as_template.id
    version = "$Latest"
  }
  vpc_zone_identifier = local.subnet_id
  tag {
    key = "Name"
    value = "server-${var.server_number[0]}"
    propagate_at_launch = true
  }
}
#-----------------------Create a new load balancer attachment-----------------------
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.as_group.id
  elb                    = aws_lb.as_alb.id
}
#-------------------------Auto Scaling policy--------------------------------
# resource "aws_autoscaling_policy" "as_policy" {        #if this resource is added the desired_capacity must be commented
#   name                   = "as-policy-test"
#   scaling_adjustment     = 4
#   adjustment_type        = "ChangeInCapacity"
#   cooldown               = 300
#   autoscaling_group_name = aws_autoscaling_group.as_group.name
# }
#---------------------Creation of the notification----------------------------
resource "aws_autoscaling_notification" "as_notifications" {
  group_names = ["aws_autoscaling_group.as_group"]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR"
  ]
  topic_arn = aws_sns_topic.as_topic.arn
}
#------------------------Creation of the topic----------------------------
resource "aws_sns_topic" "as_topic" {
  name = "as-topic"
  display_name = "as-topic"
}