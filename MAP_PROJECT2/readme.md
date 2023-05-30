# TERRAFORM
# **This is process for creating resources with Terraform**
## This repository contains the configuaration files for launch 3 Amazon Linux 2 EC2 instances in the US-west-2 region. An Application load balancer was added to distribute the traffic to only two instances.   
- The "Count function" has been use to deploy three identical instances.
- The conditional expression and the lenght function were used to generate the creation of the ELB. 
- The variable "mapping" has been use to declare the way of insert three differents instance type. 
- The infrastructure was deploy using the default VPC and Subnets.

---
We followed the best practise of Terraform recommendation by refactoring our root module. This folder will contains:

 - main.tf : the file with all resources to be create
 - variables.tf : declaration of variables to be use on themain file.
 - outputs.tf : output value of resources created on the main file.
 - providers.tf : name of the provider that will be use to communicate with the code. 

---

  Maintainer  : **Cloud Engineer JOSEPH MBATCHOU**