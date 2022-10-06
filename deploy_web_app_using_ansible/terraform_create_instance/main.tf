provider "aws" {
  region = var.AWS_REGION
}

// Create aws_ami filter to pick up the ami available in your region
data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_vpc" "prod-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = "true" #gives you an internal domain name
  enable_dns_hostnames = "true" #gives you an internal host name
  instance_tenancy = "default"

  tags = {
    Name = "deploy-web-app"
  }
}

resource "aws_subnet" "prod-subnet-public-1" {
  vpc_id = aws_vpc.prod-vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "deploy-web-app"
  }
}

resource "aws_internet_gateway" "prod-igw" {
  vpc_id = aws_vpc.prod-vpc.id
  tags = {
    Name = "deploy-web-app"
  }
}

resource "aws_route_table" "prod-public-crt" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    //associated subnet can reach everywhere
    cidr_block = "0.0.0.0/0"
    //CRT uses this IGW to reach internet
    gateway_id = aws_internet_gateway.prod-igw.id
  }

  tags = {
    Name = "deploy-web-app"
  }
}

resource "aws_route_table_association" "prod-crta-public-subnet-1"{
  subnet_id = aws_subnet.prod-subnet-public-1.id
  route_table_id = aws_route_table.prod-public-crt.id
}


resource "aws_security_group" "ssh-allowed" {
  vpc_id = aws_vpc.prod-vpc.id

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"] # Change this to your personal IP instead of leaving open to the public
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Change this to your personal IP instead of leaving open to the public
  }
  //If you do not add this rule, you can not reach the NGIX
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Change this to your personal IP instead of leaving open to the public
  }
  tags = {
    Name = "deploy-web-app"
  }
}

// Configure the EC2 instance in a public subnet
resource "aws_instance" "ec2_public" {
  count = 3

  ami                         = data.aws_ami.amazon-linux-2.id
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = var.KEY_NAME
  subnet_id                   = aws_subnet.prod-subnet-public-1.id
  vpc_security_group_ids      = [aws_security_group.ssh-allowed.id]
  availability_zone = var.AVAILABILITY_ZONE

  tags = {
    "Name" = "deploy-web-app"
  }

}