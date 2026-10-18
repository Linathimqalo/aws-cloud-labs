output "athena_database_name" {
  description = "The Athena database name"
  value       = aws_glue_catalog_database.cloudtrail_db.name
}

output "athena_table_name" {
  description = "The Athena table name"
  value       = aws_glue_catalog_table.cloudtrail_table.name
}

output "athena_workgroup" {
  description = "The Athena workgroup"
  value       = aws_athena_workgroup.main.name
}