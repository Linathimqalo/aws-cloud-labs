# -----------------------------------------------------------------------------
# 1. S3 Bucket for CloudTrail Logs
# -----------------------------------------------------------------------------
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket        = "${var.project_name}-cloudtrail-${data.aws_caller_identity.current.account_id}"
  force_destroy = true # For a lab, ensures `terraform destroy` works without hanging on logs

  tags = {
    Name = "${var.project_name}-cloudtrail-logs"
  }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_logs" {
  bucket                  = aws_s3_bucket.cloudtrail_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Policy that allows CloudTrail to write to the bucket
resource "aws_s3_bucket_policy" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AWSCloudTrailAclCheck"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:GetBucketAcl"
        Resource  = aws_s3_bucket.cloudtrail_logs.arn
      },
      {
        Sid       = "AWSCloudTrailWrite"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.cloudtrail_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = { "s3:x-amz-acl" = "bucket-owner-full-control" }
        }
      }
    ]
  })
}

data "aws_caller_identity" "current" {}

# -----------------------------------------------------------------------------
# 2. CloudTrail (Multi-Region)
# -----------------------------------------------------------------------------
resource "aws_cloudtrail" "main" {
  name                          = "${var.project_name}-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true # Detects if logs have been tampered with

  depends_on = [aws_s3_bucket_policy.cloudtrail_logs]

  tags = {
    Name = "${var.project_name}-trail"
  }
}

# -----------------------------------------------------------------------------
# 3. SNS Topic & Subscription (For Alerts)
# -----------------------------------------------------------------------------
resource "aws_sns_topic" "security_alerts" {
  name = "${var.project_name}-alerts"
}

# You will need to confirm this subscription via email!
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.security_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

/*# -----------------------------------------------------------------------------
# 4. GuardDuty (Threat Detection)
# -----------------------------------------------------------------------------
resource "aws_guardduty_detector" "main" {
  enable = true

  # Optional: Send findings every 15 minutes instead of 6 hours (useful for labs)
  finding_publishing_frequency = "FIFTEEN_MINUTES"
}*/

/*# -----------------------------------------------------------------------------
# 5. EventBridge (Routing GuardDuty Findings to SNS)
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "guardduty_findings" {
  name        = "${var.project_name}-guardduty-findings"
  description = "Capture GuardDuty findings and send to SNS"

  event_pattern = jsonencode({
    source      = ["aws.guardduty"]
    detail-type = ["GuardDuty Finding"]
  })
}

resource "aws_cloudwatch_event_target" "sns" {
  rule      = aws_cloudwatch_event_rule.guardduty_findings.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.security_alerts.arn
}

# Allow EventBridge to publish to SNS
resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.security_alerts.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "events.amazonaws.com" }
        Action    = "sns:Publish"
        Resource  = aws_sns_topic.security_alerts.arn
      }
    ]
  })
}*/

# -----------------------------------------------------------------------------
# 6. CloudWatch Log Group for CloudTrail + Metric Filters
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/aws/cloudtrail/${var.project_name}"
  retention_in_days = var.log_retention_days
}

/*# Attach the log group to CloudTrail
resource "aws_cloudtrail" "main_with_logs" {
  # This is a trick to add CloudWatch logs to an existing trail without recreating it.
  # In a real scenario, you set this during initial creation.
  # To keep it simple for this lab, we will use a separate resource or just rely on S3.
  # (Skipping for simplicity, S3 is the primary log destination).
}*/