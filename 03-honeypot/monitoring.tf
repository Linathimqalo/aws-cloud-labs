# CloudWatch alarm: instance CPU high
resource "aws_cloudwatch_metric_alarm" "honeypot_cpu" {
  alarm_name          = "honeypot-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Honeypot CPU above 80% for 15 minutes"
  alarm_actions       = []

  dimensions = {
    InstanceId = aws_instance.honeypot.id
  }

  tags = {
    Name    = "honeypot-cpu-alarm"
    Project = var.project_name
  }
}

# CloudWatch alarm: instance status check failed
resource "aws_cloudwatch_metric_alarm" "honeypot_status" {
  alarm_name          = "honeypot-status-check-failed"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "1"
  alarm_description   = "Honeypot EC2 status check failed"
  alarm_actions       = []

  dimensions = {
    InstanceId = aws_instance.honeypot.id
  }

  tags = {
    Name    = "honeypot-status-alarm"
    Project = var.project_name
  }
}