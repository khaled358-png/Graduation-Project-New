terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ------------------------------
# AWS Provider Configuration
# ------------------------------
provider "aws" {
  region = "eu-central-1"
}

# ------------------------------
# Virtual Private Cloud (VPC)
# ------------------------------
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "devops-project-vpc"
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

resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP and SSH traffic"
  vpc_id      = aws_vpc.main.id

  # ------------------------------
  # Ingress rules
  # ------------------------------

  # HTTP - Port 80
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  # SSH - Port 22
 ingress {
  description = "Allow SSH temporarily"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

  }

  # ------------------------------
  # Egress rules
  # ------------------------------
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
# EC2 Instance (Example Only)
# ------------------------------
resource "aws_instance" "app_server" {
  ami                    = "ami-1234567890"   # Placeholder, not real
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "devops-app-server"
  }
}

