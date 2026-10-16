# Runbook: Lambda + S3 + IAM

## Normal operations
- Lambda invoked on every object created in the bucket
- Records appear in DynamoDB within 1-3 seconds of upload
- CloudWatch Logs show execution details for every invocation

## Health checks

    aws lambda get-function --function-name lambda-s3-iam-process-upload
    aws dynamodb describe-table --table-name lambda-s3-iam-file-metadata

## Common troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| No DynamoDB record after upload | Lambda not triggered | Check S3 event notification, Lambda resource policy |
| Lambda error "AccessDenied" | IAM role missing permission | Check aws_iam_role_policy JSON in console |
| Logs empty | CloudWatch log group name mismatch | Verify function name matches log group prefix |
| Duplicate DynamoDB writes | S3 event retry | Implement idempotency with conditional writes |
| Lambda throttled | Reserved concurrency reached | Raise `lambda_reserved_concurrency` variable |

## Escalation
For production use: route Lambda errors to SNS or EventBridge for
alerting. Check CloudWatch Metrics -> Lambda -> Errors.

## Recovery
If the function is accidentally deleted: `terraform apply` recreates
it. S3 notifications reattach automatically.

## Cost control
- Watch CloudWatch Logs ingestion if volume increases
- Reserved concurrency prevents unbounded parallel execution
- Delete test objects from S3 when done