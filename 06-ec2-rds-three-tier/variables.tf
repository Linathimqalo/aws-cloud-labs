variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Project name used in resource names"
  type        = string
  default     = "ec2-rds-lab"
}

# IMPORTANT: We use existing subnets from Project 1
variable "vpc_id" {
  description = "VPC ID from Project 1"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet for the EC2 web server"
  type        = string
}

variable "private_data_subnet_id" {
  description = "Private data subnet for the RDS database"
  type        = string
}

variable "private_data_subnet_id_b" {
  description = "Second private data subnet for RDS subnet group (RDS requires 2 subnets in different AZs, even for single-AZ deployments)"
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance size"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "RDS storage in GB (free tier allows up to 20GB)"
  type        = number
  default     = 20
}

variable "db_engine_version" {
  description = "PostgreSQL major version (AWS picks the minor)"
  type        = string
  default     = "16"
}