variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Project name used in resource names"
  type        = string
  default     = "monitoring-detection"
}

variable "alert_email" {
  description = "Email address to receive security alerts"
  type        = string
  default     = "mqalolinathi@gmail.com"
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}