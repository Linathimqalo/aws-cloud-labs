variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "iam-access-analyzer"
}

variable "unused_access_age" {
  description = "Number of days a permission must be unused to be flagged"
  type        = number
  default     = 90
}