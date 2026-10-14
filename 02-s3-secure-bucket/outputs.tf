output "main_bucket_name" {
  description = "Name of the main secure bucket"
  value       = aws_s3_bucket.main.id
}

output "main_bucket_arn" {
  description = "ARN of the main secure bucket"
  value       = aws_s3_bucket.main.arn
}

output "logs_bucket_name" {
  description = "Name of the access logs bucket"
  value       = aws_s3_bucket.logs.id
}

output "kms_key_id" {
  description = "KMS customer-managed key ID"
  value       = aws_kms_key.s3.key_id
}

output "kms_key_alias" {
  description = "KMS alias for the key"
  value       = aws_kms_alias.s3.name
}

output "kms_key_arn" {
  description = "KMS key ARN"
  value       = aws_kms_key.s3.arn
}