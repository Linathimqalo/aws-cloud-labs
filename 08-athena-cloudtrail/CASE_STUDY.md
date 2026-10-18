# Case Study: SQL Forensics on AWS Audit Logs

## Summary
Enabled forensic investigation capabilities by deploying Amazon Athena and AWS Glue over CloudTrail S3 logs. This allows engineers to run SQL queries against AWS API activity to detect anomalies or investigate incidents.

## The problem
CloudTrail stores logs as compressed JSON files in S3. Without a query engine, security teams cannot efficiently investigate incidents. You need a way to search for specific events (like `DeleteTrail` or `PutBucketPolicy`) across millions of records.

## What I built
- **Glue Catalog Database & Table:** Defined the schema (UserIdentity, EventName, SourceIP, etc.) mapping to the CloudTrail JSON structure.
- **Partition Projection:** Configured Athena to automatically map dates to the correct S3 folders without needing a scheduled Glue Crawler.
- **Athena Workgroup:** Created an isolated query environment with an assigned S3 bucket for query results.

## Challenges and how I solved them
- **Empty Results on First Query:** The first query with a `WHERE eventname = 'CreateBucket'` returned 0 rows. Root cause: Partition projection date ranges can be off by one day due to UTC boundaries when CloudTrail writes logs. Fix: Querying without the date filter (`SELECT * FROM cloudtrail_logs LIMIT 10;`) proved the table worked.
- **IAM Permissions:** Ensure the IAM user running Athena has access to read the CloudTrail S3 bucket and write to the Athena results bucket.

## Results
- Successfully queried 47.89 KB of CloudTrail logs in 1.3 seconds.
- Created a permanent, serverless forensic query tool.