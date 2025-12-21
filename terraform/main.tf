terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ------------------------------
# AWS Provider
# ------------------------------
provider "aws" {
  region = "us-east-1"
}

# ------------------------------
# VPC
# ------------------------------
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "devops-project-vpc"
  }
}

# ------------------------------
# Internet Gateway
# ------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "devops-project-igw"
  }
}

# ------------------------------
# Public Subnet
# ------------------------------
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

# ------------------------------
# Route Table (Public)
# ------------------------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# ------------------------------
# Route Table Association
# ------------------------------
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# ------------------------------
# Security Group
# ------------------------------
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.main.id

  # SSH (مفتوح مؤقتًا)
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-security-group"
  }
}

# ------------------------------
# EC2 Instance
# ------------------------------
resource "aws_instance" "app_server" {
  ami                    = "ami-0ecb62995f68bb549" # Ubuntu
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = "my-key"

  tags = {
    Name = "Graduation-Project-New"
  }
}
output "ec2_public_ip" {
  value = aws_instance.app_server.public_ip
}

resource "null_resource" "ansible_provisioning" {
  # Trigger only when the instance is created or its IP changes
  triggers = {
    ec2_public_ip_address = join(" ", aws_instance.app_server.*.public_ip)
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]

    working_dir = "/home/khaled/project/Graduation-Project-New/ansible"

    command = <<-EOT
      set -e

      echo "Waiting for EC2 SSH to be ready..."

      # Wait for SSH on every EC2 instance
      for ip in ${join(" ", aws_instance.app_server.*.public_ip)}; do
        echo "Waiting for SSH on $ip ..."
        until nc -z -w5 $ip 22; do
          echo "SSH not ready on $ip yet... retrying in 5s"
          sleep 5
        done
        echo "SSH is ready on $ip"
      done


      echo "[webservers]" > temp_inventory

      # Loop through all instance public IPs
      for ip in ${join(" ", aws_instance.app_server.*.public_ip)}; do
        echo "$ip ansible_user=ubuntu ansible_ssh_private_key_file=/home/khaled/.ssh/my-key.pem" >> temp_inventory
      done

      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i temp_inventory deploy.yml

      rm temp_inventory
      
    EOT
  }
}
