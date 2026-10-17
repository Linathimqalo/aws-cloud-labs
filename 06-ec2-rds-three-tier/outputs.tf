output "app_server_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "app_server_url" {
  description = "URL to test the application (wait 3-4 minutes after apply)"
  value       = "http://${aws_instance.app_server.public_ip}"
}

output "db_endpoint" {
  description = "RDS PostgreSQL endpoint (private, not reachable from internet)"
  value       = aws_db_instance.postgres.address
}

output "secret_name" {
  description = "Secrets Manager secret name for the DB credentials"
  value       = aws_secretsmanager_secret.db_credentials.name
}

output "secret_arn" {
  description = "Secrets Manager secret ARN"
  value       = aws_secretsmanager_secret.db_credentials.arn
}