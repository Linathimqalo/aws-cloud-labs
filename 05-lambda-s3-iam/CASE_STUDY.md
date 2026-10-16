# Case Study: Event-Driven File Processing on AWS

## Summary
Built a serverless pipeline on AWS where S3 object uploads trigger
Lambda functions that hash file content and record metadata in
DynamoDB. The infrastructure is fully declared in Terraform with
least-privilege IAM throughout.

## The problem
Manual file processing does not scale. Teams need automated
pipelines that react to file arrival, extract metadata, and store
it for search, audit, or downstream processing. Cloud-native
architecture should be event-driven: no polling, no servers to
manage, no wasted compute.

## What I built
- S3 bucket with Block Public Access, versioning, SSE-AES256
- Lambda function (Python 3.12) that reads uploaded objects,
  computes SHA-256, and writes metadata to DynamoDB
- DynamoDB table with on-demand billing, encryption at rest,
  and a GSI on event_time for time-based queries
- IAM role with explicit per-action policies on specific resources
- CloudWatch Logs with 7-day retention
- Lambda resource policy restricting invocation to S3 events from
  this specific bucket
- Reserved concurrency to bound cost and prevent runaway load

## Architecture

              [File upload to S3]
                       |
                       | s3:ObjectCreated:*
                       v
              [Lambda: process_upload]
                       |
        +--------------+--------------+
        v                             v
[DynamoDB: file_metadata]    [CloudWatch Logs]

## Security decisions
- IAM role grants only the actions Lambda needs, on only the
  specific resources. No wildcards.
- Lambda can only be invoked by S3 events from this bucket.
  Prevents other services or accounts from triggering it.
- S3 bucket blocks all public access at four levels. Enforced
  object ownership disables ACLs entirely.
- DynamoDB encryption at rest, default AWS-managed key.
- No credentials stored in Lambda code; uses execution role.
- Reserved concurrency of 5 prevents DoS via upload flood
  and bounds cost.

## Real execution observations

From CloudWatch Logs analysis of the first two invocations:

**Cold vs warm start:**
- Cold: 500ms init + 462ms execution = 964ms billed
- Warm: 452ms execution, no init
- Cold start roughly doubles the billed duration. For low-volume
  workloads this is negligible. For latency-sensitive endpoints,
  provisioned concurrency eliminates it at added cost.

**Memory profile:**
- Allocated: 128 MB
- Max used: 100 MB (78% utilization)
- Any larger file would risk OOM. For production, allocate 256 MB
  for headroom, or stream the hash instead of loading the whole
  object into memory.

**Event payload structure:**
- S3 sends a rich event with bucket ARN, object key, size, ETag,
  version ID, principal ID, source IP, and request ID.
- Object keys with spaces are URL-encoded with `+` characters.
  Must decode with `urllib.parse.unquote_plus`.
- `configurationId` starts with `tf-s3-lambda-` proving the
  notification was created by Terraform.

**Deterministic hashing:**
- SHA-256 computed by Lambda matches local `sha256sum` exactly.
- Versioning is active: every upload has a unique versionId.
- Upload to DynamoDB latency: ~1.5 seconds end to end.

## Challenges and how I solved them

**Reserved concurrency rejected on new accounts.** AWS enforces an
unreserved concurrency floor of 10. Setting reserved concurrency to 5
on an account with a total limit of 10 would drop unreserved below the
floor. Removed the reserved concurrency setting. Alternative: request
a Service Quotas increase first. Documented as a common gotcha for
new accounts.

**Terraform tainted state after failed apply.** When Lambda creation
failed mid-apply, Terraform marked the resource as tainted. The next
plan showed "destroy and create replacement." Allowed Terraform to
handle it. Result: clean state, no orphaned resources.

**Git Bash path mangling.** `aws logs tail /aws/lambda/...` failed
because MSYS auto-converts `/aws/...` to a Windows path. Fix: set
`MSYS_NO_PATHCONV=1` in `.bashrc`. Prevents future commands from
being mangled.

**URL-encoded S3 event keys.** Object keys with spaces arrive as
`my%20test%20file.txt`. Handler uses `urllib.parse.unquote_plus`
to recover the original key. Verified by uploading a file with
spaces and confirming the DynamoDB record shows the decoded key.

## Results

- 13 resources deployed in 60 seconds
- End-to-end upload-to-DynamoDB latency: under 5 seconds
- SHA-256 computed by Lambda matches local `sha256sum` exactly
- URL-encoded key handling verified with spaces in filename
- Zero Lambda errors after successful deployment
- Cost: $0.00 (all components within Free Tier limits)
- CloudWatch log retention set to 7 days, avoiding indefinite cost

## Skills demonstrated
- Event-driven architecture with S3 event notifications
- Lambda function development in Python
- IAM least-privilege design
- DynamoDB modeling with GSI
- Terraform for serverless resources
- CloudWatch Logs for observability
- Testing an end-to-end pipeline

## What I would do differently
(To fill in.)

## Links
GitHub: /05-lambda-s3-iam

## About
Cloud security and infrastructure engineer building practical
skills in AWS, Terraform, and detection engineering.