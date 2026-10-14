# Project 2: S3 Secure Bucket

Deployed a hardened S3 bucket on AWS with Terraform, with KMS
customer-managed encryption and access logging.

## Architecture

- 1 main S3 bucket with:
  - Block Public Access (all 4 settings enabled)
  - Versioning enabled
  - SSE-KMS encryption with customer-managed key
  - Bucket key enabled for cost reduction
  - Bucket policy denying non-TLS requests
  - Bucket policy denying unencrypted uploads
  - Access logging to a separate bucket
  - Lifecycle rule to expire old versions after 30 days
- 1 logging bucket with its own public access block and encryption
- 1 KMS customer-managed key with rotation enabled

## Design choices

- **Customer-managed KMS key, not AWS-managed.** Gives you control
  over key policy, rotation schedule, and audit trail via CloudTrail.
- **Bucket key enabled.** Reduces KMS API call costs by up to 99%
  when serving high-volume traffic. No security downside.
- **Object ownership enforced.** Disables ACLs entirely, so access is
  controlled only by bucket policy and IAM. Removes a common
  misconfiguration class.
- **Deny non-TLS.** Encrypts all data in transit, not just at rest.
- **Deny unencrypted uploads.** Prevents accidental unencrypted PUTs
  even if the caller tries to override the default.
- **Separate logging bucket.** Best practice to isolate access logs.
- **7-day KMS deletion window.** Balances safety against accidental
  deletion with cleanup convenience.

## Cost

- S3 storage under 5GB: free
- KMS key: $1/month (prorated, destroyed at end of session)
- KMS API calls: under 20,000 free tier
- Total for this project: under $0.10

## Usage

    cd 02-s3-secure-bucket
    terraform init
    terraform plan
    terraform apply

To tear down:

    terraform destroy

Note: KMS key deletion is scheduled for 7 days after destroy. You
cannot cancel this once applied. The key will show as "Pending Deletion"
in the KMS console for that window.

## What I learned

- **CLI behavior differs from server-side defaults.** AWS CLI on
  Windows Git Bash sends `AES256` as the default SSE header, not
  `aws:kms`. Bucket policies that require `aws:kms` via
  `StringNotEqualsIfExists` force explicit `--sse aws:kms` on
  every upload. This is intentional security posture: callers
  must declare their encryption intent.

- **AWS-managed vs customer-managed KMS keys.** AWS automatically
  creates an `aws/s3` AWS-managed key when S3 encryption is used.
  This key is free, unmanaged, and cannot be deleted. Customer
  managed keys (CMKs) cost $1/month, support rotation, policy
  control, and CloudTrail audit. Both are visible in
  `aws kms list-keys`, but only CMKs bill you.

- **Bucket default encryption applies only when no key is
  specified.** Objects uploaded with an explicit `--sse-kms-key-id`
  use that key. Objects uploaded without any KMS key specified
  use the AWS-managed default, even if the bucket has a
  customer-managed default. To force the CMK, always specify
  the full key ARN.

- **`BoolIfExists` vs `Bool` on `aws:SecureTransport`.** Used
  `BoolIfExists` because the Windows Git Bash CLI sometimes does
  not populate `aws:SecureTransport` in the request context.
  In production SDKs, `Bool` is stricter and standard. For
  mixed-platform environments, `BoolIfExists` is safer.

- **SSE-C blocked by default.** AWS now blocks SSE-C (customer
  provided keys) by default on new buckets. This is visible in
  the bucket encryption configuration as `BlockedEncryptionTypes`.

## Screenshots

- (add console screenshots after apply)