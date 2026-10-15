variable "aws_region" { default = "eu-north-1" }
variable "project_name" { default = "honeypot" }
variable "vpc_id" { description = "Existing VPC ID" }
variable "public_subnet_id" { description = "Public Subnet A ID" }
variable "admin_cidr" { description = "Your public IP in CIDR, e.g. 1.2.3.4/32" }