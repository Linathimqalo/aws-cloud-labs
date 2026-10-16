# Project 5: Lambda + S3 + IAM (Event-Driven Pipeline)

## What this is
A serverless pipeline where file uploads to S3 trigger a Lambda
function that computes a SHA-256 hash and stores metadata in
DynamoDB. Demonstrates event-driven architecture with least-privilege
IAM, Terraform-managed infrastructure, and full observability.

## Why this matters in a real job
Event-driven serverless is the modern default for:
- File ingestion and processing (images, documents, logs)
- Security automation (quarantine, scan, tag on upload)
- Data pipelines (ETL triggered by object arrival)
- Alert enrichment (S3 event -> Lambda -> enrich -> forward)

The pattern shows up in every serious AWS account. Interviewers
ask about Lambda triggers, cold starts, IAM scoping, error handling,
and idempotency. This project touches all of those.

## Architecture

              [File upload to S3]
                       |
                       | s3:ObjectCreated:*
                       v
              [Lambda: process_upload]
                       |
        +--------------+--------------+
        |                             |
        v                             v
[DynamoDB: file_metadata]    [CloudWatch Logs]

## Design decisions and tradeoffs

| Decision | Alternative | Why |
|----------|-------------|-----|
| S3 event -> Lambda direct | S3 -> SQS -> Lambda | Direct is simpler. SQS adds resilience for high volume, retries, and DLQ. We add DLQ in a later project. |
| AES256 (SSE-S3) | SSE-KMS with CMK | KMS was covered in Project 2. Here we optimize for simplicity. |
| Python 3.12 | Node.js, Go, Java | Fast cold start, easy to read, common in security tooling. |
| Reserved concurrency = 5 | Unreserved | Prevents runaway cost if S3 receives a burst. Also protects downstream DynamoDB. |
| DynamoDB on-demand | Provisioned with autoscaling | On-demand is free-tier friendly and matches unpredictable load. |
| Least-privilege IAM | `s3:*`, `dynamodb:*` | Explicit per-action on specific resources. Passes any security review. |
| Log retention 7 days | Unlimited | Cost control and clean account hygiene. |

## Security posture

- Lambda IAM role allows only:
  - `s3:GetObject`, `s3:GetObjectVersion`, `s3:HeadObject` on this bucket only
  - `dynamodb:PutItem` on this table only
  - `logs:CreateLogStream`, `logs:PutLogEvents` on this log group only
- Lambda resource policy restricts invocation to S3 events from this bucket
- S3 bucket: Block Public Access (all 4 settings), versioning, SSE-AES256, no ACLs
- DynamoDB: encryption at rest (AWS-managed), no point-in-time recovery (cost control)
- No credentials stored in code; Lambda uses its execution role

## Cost model
- Lambda: free tier 1M requests, 400,000 GB-seconds per month
- S3: free tier 5GB
- DynamoDB: free tier 25GB, 200M requests
- CloudWatch Logs: free tier 5GB ingestion
- Estimated usage: <$0.01 per month for lab workload
- Reserved concurrency does not cost, only limits

## Common failure modes
- Lambda timeout if object larger than memory allows during hash
- IAM permission denied if bucket ARN or table ARN changes
- Event duplication: S3 can deliver a single event more than once; downstream must be idempotent
- Cold start adds 500-800ms to first invocation after idle

## Related services
- AWS EventBridge (alternative trigger, richer routing)
- AWS Step Functions (orchestrate multiple Lambdas)
- AWS SQS (buffer, retry, DLQ)
- AWS SNS (fan-out, email/SMS notifications)
- AWS X-Ray (distributed tracing)

## Teardown

    cd 05-lambda-s3-iam
    terraform destroy

## What I learned

- **Reserved concurrency has a floor.** New accounts have limited
  Lambda concurrency. Reserving any amount reduces the unreserved
  pool below a minimum of 10. Skip reserved concurrency on small
  accounts, or request a quota increase first.
- **Terraform tainted state is recoverable.** A failed apply leaves
  the resource marked for replacement on the next plan. No manual
  cleanup needed; Terraform handles it.
- **Git Bash mangles AWS paths.** Prefix-leading-slash arguments are
  auto-converted to Windows paths. Fix with `MSYS_NO_PATHCONV=1`.
- **S3 event keys are URL-encoded.** Spaces become `%20`. Always use
  `urllib.parse.unquote_plus` (or equivalent) in the handler.
- **Idempotency is not automatic.** Same key uploaded twice overwrites
  the DynamoDB record because the primary key is the object key. For
  audit-grade pipelines, use conditional writes or a composite key.
- **Reserved concurrency protects cost, but the account limit is a
  natural cap too.** On a small account, you get cost protection by
  default.