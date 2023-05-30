# OUTPUTS SECTION

#output of the public Ip 
output "instance_public_Ip" {
  value = aws_instance.server[*].public_ip
}
#output of the pivate Ip 
output "instance_private_Ip" {
  value = aws_instance.server[*].private_ip
}
#output of the security group Id
output "security_group_web_sg" {
  value = aws_security_group.web_sg.id
}
#output of the vpc
output "vpc_id" {
  value = aws_vpc.vpc.id
}
#output of the public Ip 
output "instance_Ids" {
  value = aws_instance.server[*].id
}
#output of the arn of the alb
output "alb_arn" {
  value = aws_lb.my_alb[*].arn
}
#output of the dns name of the alb
output "alb_dns" {
  value = aws_lb.my_alb[*].dns_name
}


