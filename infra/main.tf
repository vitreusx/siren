terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

variable "aws_region" {
  description = "AWS region for the cluster"
  default     = "us-east-1"
}

variable "web_port" {
  description = "Web port to be used"
  default     = "3000"
}

variable "server_port" {
  description = "Server port to be used"
  default     = "8001"
}

provider "aws" {
  profile = "default"
  region  = var.aws_region
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "tls_private_key" "cluster_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "aws_cluster_key" {
  public_key = tls_private_key.cluster_key.public_key_openssh
}

resource "local_file" "cluster_key_pem" {
  filename          = "id.pem"
  file_permission   = "600"
  sensitive_content = tls_private_key.cluster_key.private_key_pem
}

resource "aws_default_vpc" "default" {}

resource "aws_security_group" "cluster_sg" {
  vpc_id = aws_default_vpc.default.id

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

resource "aws_instance" "control_planes" {
  count                  = 1
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.aws_cluster_key.key_name
  vpc_security_group_ids = [aws_security_group.cluster_sg.id]

  tags = {
    Name = "Control Plane #${count.index}"
  }
}

output "control_planes_ips" {
  description = "Public IP addresses of the Control Planes"
  value       = [aws_instance.control_planes.*.public_ip]
}

resource "aws_instance" "nodes" {
  count                  = 4
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.nano"
  key_name               = aws_key_pair.aws_cluster_key.key_name
  vpc_security_group_ids = [aws_security_group.cluster_sg.id]

  tags = {
    Name = "Node #${count.index}"
  }
}

output "nodes_ips" {
  description = "Public IP addresses of the Nodes"
  value       = [aws_instance.nodes.*.public_ip]
}

data "aws_subnet_ids" "default_subnet_ids" {
  vpc_id = aws_default_vpc.default.id
}

resource "aws_lb" "load_balancer" {
  subnets            = data.aws_subnet_ids.default_subnet_ids.ids
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.cluster_sg.id]
}

resource "aws_lb_target_group" "server" {
  vpc_id      = aws_default_vpc.default.id
  target_type = "instance"
  protocol    = "HTTP"
  port        = var.server_port
}

resource "aws_lb_listener" "server" {
  load_balancer_arn = aws_lb.load_balancer.id
  protocol          = "HTTP"
  port              = var.server_port

  default_action {
    target_group_arn = aws_lb_target_group.server.id
    type             = "forward"
  }
}

resource "aws_lb_target_group" "web" {
  vpc_id      = aws_default_vpc.default.id
  target_type = "instance"
  protocol    = "HTTP"
  port        = var.web_port
}

resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.load_balancer.id
  protocol          = "HTTP"
  port              = var.web_port

  default_action {
    target_group_arn = aws_lb_target_group.web.id
    type             = "forward"
  }
}

