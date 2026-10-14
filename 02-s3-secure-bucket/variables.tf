variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Project name used in resource tags"
  type        = string
  default     = "s3-secure-bucket"
}

variable "bucket_prefix" {
  description = "Prefix for S3 bucket names (must be lowercase, globally unique after suffix)"
  type        = string
  default     = "linathi-secure-lab"
}