variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Project name used in resource names"
  type        = string
  default     = "athena-cloudtrail"
}

variable "cloudtrail_bucket_name" {
  description = "The S3 bucket where CloudTrail logs are stored (from Project 7)"
  type        = string
}