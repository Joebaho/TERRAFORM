# OUTPUTS SECTION

#-----------------------------------output of the security group Id-------------------------------------------
output "security_group_web_sg" {
  value = aws_security_group.web_sg.id
}
#--------------------------------------output of the vpc------------------------------------------------------
output "vpc_id" {
  value = aws_vpc.vpc.id
}
#-----------------------------------------output of the arn of the alb-----------------------------------------
output "alb_arn" {
  value = aws_lb.as_alb.arn
}
#-----------------------------------------output of the dns name of the alb-------------------------------------
output "alb_dns" {
  value = aws_lb.as_alb.dns_name
}


