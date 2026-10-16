output "external_analyzer_arn" {
  description = "ARN of the external access analyzer"
  value       = aws_accessanalyzer_analyzer.external.arn
}

output "external_analyzer_id" {
  description = "ID of the external access analyzer"
  value       = aws_accessanalyzer_analyzer.external.id
}

output "unused_analyzer_arn" {
  description = "ARN of the unused access analyzer"
  value       = aws_accessanalyzer_analyzer.unused.arn
}

output "unused_analyzer_id" {
  description = "ID of the unused access analyzer"
  value       = aws_accessanalyzer_analyzer.unused.id
}