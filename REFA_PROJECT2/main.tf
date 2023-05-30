# Declaration of the ec2 security group
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
#EC2_1 creation
resource "aws_instance" "server" {
  count                       = 3
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.instance_type
  subnet_id                   = element(local.subnet_id, count.index)
  availability_zone           = data.aws_availability_zones.az.names[count.index]
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = "true"
  user_data                   = <<-EOF
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
    Name = "sever-${count.index + 1}"
  }
}






