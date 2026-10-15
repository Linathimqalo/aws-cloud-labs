# -----------------------------------------------------------------------------
# Data sources
# -----------------------------------------------------------------------------

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# -----------------------------------------------------------------------------
# IAM Role + Instance Profile for SSM Session Manager
# -----------------------------------------------------------------------------

resource "aws_iam_role" "honeypot" {
  name = "${var.project_name}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-ssm-role"
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.honeypot.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "honeypot" {
  name = "${var.project_name}-profile"
  role = aws_iam_role.honeypot.name
}

# -----------------------------------------------------------------------------
# Security Group
# -----------------------------------------------------------------------------

resource "aws_security_group" "honeypot" {
  name        = "${var.project_name}-sg"
  description = "T-Pot honeypot SG"
  vpc_id      = var.vpc_id

  # Management ports: restricted to your IP only
  ingress {
    description = "SSH (T-Pot shifted)"
    from_port   = 64295
    to_port     = 64295
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  ingress {
    description = "Cockpit"
    from_port   = 64294
    to_port     = 64294
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  ingress {
    description = "NGINX reverse proxy (Kibana etc.)"
    from_port   = 64297
    to_port     = 64297
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  # Honeypot attack surface: exposed to the world
  ingress {
    description = "Honeypot attack ports TCP"
    from_port   = 1
    to_port     = 64293
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Honeypot attack ports UDP"
    from_port   = 1
    to_port     = 64293
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

# -----------------------------------------------------------------------------
# EC2 Instance
# -----------------------------------------------------------------------------

resource "aws_instance" "honeypot" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "m7i-flex.large"
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.honeypot.id]
  iam_instance_profile   = aws_iam_instance_profile.honeypot.name

  root_block_device {
    volume_size = 40
    volume_type = "gp3"
  }

  user_data = <<-EOF
                                                                                                                                                                                                                                                                                                              #!/bin/bash
                                                                                                                                                                                                                                                                                                                  apt update
                                                                                                                                                                                                                                                                                                                      apt install -y git curl
                                                                                                                                                                                                                                                                                                                        EOF

  tags = {
    Name = "${var.project_name}-ec2"
  }

  depends_on = [
    aws_iam_role_policy_attachment.ssm
  ]
}