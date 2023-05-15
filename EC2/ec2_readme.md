# **This is ReadMe process for Amazon Linux EC2 creation with Terraform**
## _This repository contains the configuaration files and all others files needed for Terraform_

---
To launch an Linux EC2 on AWS using Terraform you must follow 
- Create the configuration file and save it in a loacal folder
- Initialize the folder by typing the CLI command 'terraform init'
* Validate the code with command 'terraform validate'
* View all resources created with the commad 'terraform plan'
- build the resourcewith thecommand 'terraform apply'

---
The configuration file is structured:
- Creation of the terraform block: Choose of the provider
- Enter the provider: AWS
- Creation of the resource : Amazon Linus EC2 Instance.