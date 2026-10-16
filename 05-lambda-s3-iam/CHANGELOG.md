# Changelog

## 2026-10-17
- Initial Terraform for Lambda, S3, DynamoDB, IAM
- Lambda handler in Python 3.12
- Documentation standard applied

## 2026-10-17 (deployment attempts)

**Attempt 1 failed:** Set reserved concurrency to 5. AWS rejected with
"Specified ReservedConcurrentExecutions for function decreases account's
UnreservedConcurrentExecution below its minimum value of [10]."

**Root cause:** New AWS accounts start with a low Lambda concurrency
limit (likely 10 total). Reserving any amount reduces the unreserved
pool, and the floor for unreserved is 10. So reserving 5 on an account
with 10 total would leave 5 unreserved, below the floor.

**Fix:** Removed reserved concurrency. Lambda runs on the shared
unreserved pool. Cost protection is lost, but the account limit itself
provides a natural cap.

**Learning:** Reserved concurrency is not free to configure on new
accounts. To use it, request a concurrency limit increase through
AWS Service Quotas first.

## 2026-10-17 (deployment complete)

- Deployed 13 resources in eu-north-1
- Hit reserved concurrency error on first apply:
  "Specified ReservedConcurrentExecutions for function decreases account's
  UnreservedConcurrentExecution below its minimum value of [10]."
  Fix: removed reserved concurrency. Documented as new-account limitation.
- Lambda function was tainted after failed apply. Terraform replaced it
  cleanly. Final apply: 3 added, 1 destroyed, 0 changed.
- End-to-end test:
  - Uploaded test-upload.txt (21 bytes) to S3
  - Lambda triggered within 5 seconds
  - DynamoDB record created with correct SHA-256
  - Local sha256sum matches DynamoDB value exactly:
    081b1f86892b97da2d4df5fe8713b856e730a1cec16dc30ca025992555a48991
- URL-encoded key test:
  - Uploaded "my test file.txt" (with spaces)
  - S3 event delivered URL-encoded key
  - Lambda unquote_plus decoded correctly
  - Second record created, table Count = 2
- Git Bash log tail error encountered:
  aws logs tail /aws/lambda/... fails because MSYS converts path
  Fix: export MSYS_NO_PATHCONV=1 in ~/.bashrc