# main.tf
variable "path" {
  type    = string
}

# Read variables from JSON file
locals {
  vars = jsondecode(file(var.path))
}

# Configure the AWS provider
provider "aws" {
  region = local.vars.aws_region
}

# Create a VPC
resource "aws_vpc" "vpc_ue" {
  cidr_block = "11.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc_ue"
  }
}

# Create a subnet in the VPC
resource "aws_subnet" "subnet_ue" {
  vpc_id                  = aws_vpc.vpc_ue.id
  cidr_block             = "11.0.1.0/24"
  availability_zone       = local.vars.zone # e.g., us-east-1a
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet_ue"
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "igw_ue" {
  vpc_id = aws_vpc.vpc_ue.id

  tags = {
    Name = "igw_ue"
  }
}


# Create a routing table
resource "aws_route_table" "route_table_ue" {
  vpc_id = aws_vpc.vpc_ue.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_ue.id
  }

  tags = {
    Name = "route_table_ue"
  }
}

# Associate the subnet with the routing table
resource "aws_route_table_association" "route_table_association_ue" {
  subnet_id      = aws_subnet.subnet_ue.id
  route_table_id = aws_route_table.route_table_ue.id
}

# Create a security group to allow SSH, HTTP traffic
resource "aws_security_group" "allow_traffic" {
  name        = "allow-traffic"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.vpc_ue.id

#  ingress {
#    from_port   = 22
#    to_port     = 22
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


# Create an EC2 instance
resource "aws_instance" "UERANSIM" {
  ami             = local.vars.created_AMI # Replace with your actual AMI ID
  instance_type   = local.vars.aws_instance
  subnet_id       = aws_subnet.subnet_ue.id

  key_name        = local.vars.key_pair # Replace with your actual key pair name

  # Allow SSH, HTTP traffic
  vpc_security_group_ids = [aws_security_group.allow_traffic.id]

  associate_public_ip_address = true

  tags = {
    Name = "UERANSIM"
  }
}

output "ue_public_ip" {
  value = aws_instance.UERANSIM.public_ip
}
