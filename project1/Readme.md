# TERRAFORM
# **This is the process for creating resources with Terraform**
## _This repository contains the configuaration files for create a VPC, subnets (Public and Private), route table, Nacl and launch an Amazon Linux 2 EC2 instance in a pluclic subnet in the US-west-2 region._

---
To create an infrastructure on AWS using Terraform you must follow these steps: 
- Create the configuration file with extention .tf then save it in a loacal folder
- Initialize the folder by typing the CLI command 'terraform init'
* Validate the code with command 'terraform validate'
* View all resources created with the commad 'terraform plan'
- build the resource with thecommand 'terraform apply'

---
The configuration file is structured:
- Creation of the terraform block: Choose the provider
- Enter the provider: AWS
- Creation of the resource : VPC, subnets,IGW, Route table, Nacl,SG, EC2...
- Creation of variable and data source. 
- All variablea are store in a seoparate file name terraform.tfvars 

 This project is maintain by : Joseph Mbatchou