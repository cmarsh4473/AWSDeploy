data "aws_ami" "amazon_linux" {
  most_recent = true
  owners       = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_security_group" "web" {
  name        = "${var.name}-sg"
  description = "Allow SSH and HTTP"

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.ssh_cidr]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-sg"
  }
}

resource "aws_key_pair" "deployer" {
  count      = var.public_key_path != "" ? 1 : 0
  key_name   = "${var.name}-key"
  public_key = file(var.public_key_path)
}

locals {
  key_name = length(aws_key_pair.deployer) > 0 ? aws_key_pair.deployer[0].key_name : null
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = local.key_name
  vpc_security_group_ids = [aws_security_group.web.id]

  tags = {
    Name = var.name
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y

              # Install Docker
              amazon-linux-extras install -y docker
              systemctl enable docker
              systemctl start docker

              # Allow ec2-user to run docker without sudo
              usermod -aG docker ec2-user

              # Pull and run a simple nginx container to serve a welcome page
              docker pull nginx:stable
              docker run --name welcome -d -p 80:80 --restart unless-stopped nginx:stable

              EOF
}
