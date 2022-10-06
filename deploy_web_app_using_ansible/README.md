# Project Description

You are a Cloud engineer working for an I.T firm and your Boss wants you to deploy a web application to 3 ec2 amazon Linux instances simultaneously. After meeting with him, he suggested you use ansible to achieve this task.

## STEPS TO FOLLOW

- Create the first sg (main-sg), enable ssh from your IP
- Create the second sg (ec2-sg), enable ssh from main-sg, and enable HTTP from port 80
- Launch the ansible-ec2
- ssh into the ansible-ec2
- Create key pairs on the ansible-ec2
- import the public key into the ec2 console (ansible-ec2-pub-key)
- launch the remaining 3 servers. keypair: ansible-ec2-pub-key | Security group: ec2-sg
- test your connection -> ssh into other ec2 servers using their specific private IPs while on the ansible-ec2
- Install ansible on the ansible-ec2
- create inventory file
- create playbook
- ansible all --key-file ~/.ssh/id_rsa -i inventory -m ping -u ec2-user
- Create ansible.cfg file
- run the ansible-playbook 

## Project Perequisites
- Working Knowledge of git
- knowledge of AWS management console
- Knowledge of AWS Service (EC2, security groups)
- How to Create Ansible Playbook, Inventory, and Config file

## Hint
- All EC2 servers to be amazon Linux 2
- Create your own ansible-playbook (.yml)
- Create configure file (.cfg)
- create an inventory file
- sg is security group
- pub-key is public key
- EC2 is Amazon Elastic Compute Cloud


## SOLUTION CREATED ON MAC
- Create key_pair on aws UI name it `deploy-web-app`
  - on your terminal `chmod 400 deploy-web-app.pem`
- Used Terraform to create aws resources.
  - Terraform script is in the `terraform_create_instance` folder
  - terraform init
  - terraform plan
  - terraform apply
  - Remember to change the security group cidr_blocks to you personal ip
- ssh to each server using your key
  - e.g. `ssh -i "deploy-web-app.pem" ec2-user@ec2-35-183-198-162.ca-central-1.compute.amazonaws.com`
- Used ansible to deploy webserver to the instances created above
  - Ansible playbook is in the `ansible_things` folder
  - add the public dns of the instance to the `server_host` file
  - run ansible playbook 
    - ansible-playbook -i server_hosts install_server.yml  --user ec2-user --key-file ~/Downloads/deploy-web-app.pem
- on your browser type `http://<public-dns-of-your-server>`

## Improvement to solution
- create key pair with terraform
- wrapper solution into a python script so it can be fully one-click


### Notes (Debugging process)
- Create Security group on AWS to allow ssh and http 
- create 1 instance to see what is needed to deploy apache server
Fix problem
- COuld not ssh to instance after creating it 
  - Security group for ssh from my ip exist
  - Nacl allows connection exist
  - private route table did not have any way to internet gateway
    - added 0.0.0.0/0 for IPv4 that points to an internet gateway.
    - able to ssh when sg was set to allow from 0.0.0.0/0
    - to lock it down use value from google search my ip instead of the IP aws will give when you say from `my ip`

#### Installing webserver
- sudo su
- yum update -y
- yum install httpd -y
- service httpd start
- service httpd start
- chkconfig httpd on
- cd /var/www/html 
  - put website in that folder

#### Automating with Ansible playbook
- create an hosts file and add your instance dns to it
- create you ansible role and automate the server installation process

n.b : to run ansible use -
ansible-playbook   ansible_things/install_server.yml -i ansible_things/server_hosts --user ec2-user -key-file <Your_Private_key_file.pem> 


## 