# -----------------------------------------------------------------------------
# 1. RDS Setup (Database Tier)
# We create this first because the app server depends on the DB configuration.
# -----------------------------------------------------------------------------

# Generate a random password for the database.
# Why? Never hardcode passwords in Terraform or Git.
resource "random_password" "db_password" {
  length  = 24
  special = false # Special characters can sometimes break connection strings or command-line tools.
}

# Store the password in Secrets Manager.
# Why Secrets Manager instead of just passing it to RDS?
# Because the EC2 instance needs the password. If we don't use Secrets Manager,
# we would have to hardcode it in the user_data script. Secrets Manager lets
# the EC2 instance fetch it securely at runtime via its IAM role.
resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "${var.project_name}-db-credentials"
  recovery_window_in_days = 0 # 0 means immediate deletion. Safe for a lab to avoid extra charges. In production, use 7-30 days.
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = "dbadmin"
    password = random_password.db_password.result
    engine   = "postgres"
    host     = aws_db_instance.postgres.address
    port     = aws_db_instance.postgres.port
    dbname   = "appdb"
  })
}

# Security Group for RDS
# Why? To control exactly who can talk to the database.
resource "aws_security_group" "db_sg" {
  name        = "${var.project_name}-db-sg"
  description = "Allow PostgreSQL from App Tier only"
  vpc_id      = var.vpc_id

  # INGRESS: Allow PostgreSQL traffic ONLY from the App Security Group.
  # We do not use a CIDR block here. We use a Security Group ID as the source.
  # This means only instances with the app_sg attached can reach port 5432.
  ingress {
    description     = "PostgreSQL from App SG"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  # EGRESS: Allow all outbound (default). RDS needs this for patching and management.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-db-sg"
  }
}

# RDS Subnet Group
# Why? RDS requires a subnet group spanning at least two AZs,
# even if you are only deploying a single instance.
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = [var.private_data_subnet_id, var.private_data_subnet_id_b]

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# RDS PostgreSQL Instance
resource "aws_db_instance" "postgres" {
  identifier        = "${var.project_name}-postgres"
  engine            = "postgres"
  engine_version    = var.db_engine_version # Pin the version to avoid unexpected upgrades
  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage

  # RDS requires a username. Password comes from the random_password resource.
  db_name  = "appdb"
  username = "dbadmin"
  password = random_password.db_password.result

  # NETWORKING
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  publicly_accessible    = false # CRITICAL: This ensures the DB has no public IP.

  # LIFECYCLE & BACKUPS
  # For a lab, we disable backups to save costs and speed up creation.
  # In production, set backup_retention_period to >= 7.
  backup_retention_period = 0
  skip_final_snapshot     = true # Required if we want `terraform destroy` to work without hanging.

  # ENCRYPTION
  # For a lab, default AWS-managed KMS key is fine.
  storage_encrypted = true

  tags = {
    Name = "${var.project_name}-postgres"
  }
}

# -----------------------------------------------------------------------------
# 2. EC2 Setup (App Tier)
# -----------------------------------------------------------------------------

# IAM Role for EC2
# Why? The EC2 instance needs to assume a role to use SSM and Secrets Manager.
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

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
    Name = "${var.project_name}-ec2-role"
  }
}

# IAM Policy for EC2
# Least privilege: SSM for management, Secrets Manager for the DB password.
resource "aws_iam_role_policy" "ec2_policy" {
  name = "${var.project_name}-ec2-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSSM"
        Effect = "Allow"
        Action = [
          "ssm:UpdateInstanceInformation",
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Resource = "*" # SSM requires Resource: "*" for these channel actions
      },
      {
        Sid    = "AllowSecretsManager"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = aws_secretsmanager_secret.db_credentials.arn
      },
      {
        Sid    = "AllowCloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.app_logs.arn}:*"
      }
    ]
  })
}

# Attach the AWS managed policy for SSM (best practice to use the managed policy)
resource "aws_iam_role_policy_attachment" "ssm_managed" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance Profile: Needed to attach the IAM role to the EC2 instance.
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# Security Group for App Server
resource "aws_security_group" "app_sg" {
  name        = "${var.project_name}-app-sg"
  description = "Allow HTTP from internet, SSM access"
  vpc_id      = var.vpc_id

  # INGRESS: HTTP from the internet (for the app to be reachable)
  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # NO SSH PORT OPEN. We rely entirely on SSM.

  # EGRESS: Allow outbound for packages, RDS connection, and SSM.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-app-sg"
  }
}

# CloudWatch Log Group for the app
# Why? EC2 user_data doesn't automatically log application output to CloudWatch.
# We install the CloudWatch agent in user_data and push our Flask logs here.
resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/aws/ec2/${var.project_name}/app"
  retention_in_days = 7
}

# Fetch the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["137112412989"] # Amazon
}

# EC2 Instance
resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  # The user_data script now receives the password directly as an argument
  user_data = templatefile("${path.module}/user_data.sh", {
    db_password = random_password.db_password.result
  })

  # CRITICAL: Ensures Terraform destroys and recreates the instance
  # if the user_data script changes, forcing it to run again.
  user_data_replace_on_change = true

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.project_name}-app-server"
  }

  # CRITICAL: Ensure EC2 only boots AFTER the database is ready
  # and the secret is written. Prevents race conditions.
  depends_on = [
    aws_db_instance.postgres,
    aws_secretsmanager_secret_version.db_credentials
  ]
}