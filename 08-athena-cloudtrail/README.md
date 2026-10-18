# Project 8: Athena for CloudTrail (Forensics)

## What this is
A serverless SQL query interface for CloudTrail logs. It uses AWS Glue to define the schema of the JSON logs and Amazon Athena to run SQL queries directly against the S3 bucket.

## Why this matters in a real job
If an IAM key is compromised, you cannot manually read millions of JSON log files in S3 to figure out what the attacker did. You use Athena. This allows you to ask questions like:
- "Which IP addresses deleted S3 buckets in the last 24 hours?"
- "What did the user 'linathi-admin' do at 3 AM?"

## Design decisions
| Decision | Alternative | Why we chose this |
|----------|-------------|-------------------|
| Partition Projection | AWS Glue Crawler | A crawler takes time and incurs costs. Partition projection tells Athena to calculate the partitions dynamically based on a date range. |
| JSON SerDe | Parquet | CloudTrail writes JSON. We parse it natively rather than converting it to a columnar format first. |
| Athena Workgroup | Default Primary | Enforces a dedicated S3 output location and allows cost controls. |