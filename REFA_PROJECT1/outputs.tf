# OUTPUTS SECTION

#output of the public Ip 
output "instance_public_Ip" {
  value = aws_instance.my_ec2.public_ip
}
#output of the pivate Ip 
output "instance_private_Ip" {
  value = aws_instance.my_ec2.private_ip                        
}
#output of the security group Id
 output "security_group_web_sg" {
  value = aws_security_group.web_sg.id
}

