output "cloudtrail_bucket_name" {
  description = "S3 bucket receiving CloudTrail logs"
  value       = aws_s3_bucket.cloudtrail_logs.id
}

output "sns_topic_arn" {
  description = "SNS Topic for security alerts"
  value       = aws_sns_topic.security_alerts.arn
}

/*output "guardduty_detector_id" {
  description = "GuardDuty Detector ID"
  value       = aws_guardduty_detector.main.id
}*/

output "alert_email" {
  description = "The email address subscribed to alerts"
  value       = var.alert_email
}