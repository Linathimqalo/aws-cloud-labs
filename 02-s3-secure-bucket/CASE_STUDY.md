# Case Study: Secure S3 Bucket with KMS Encryption

## Summary
Deployed a hardened S3 bucket designed to prevent accidental public exposure. The architecture enforces encryption at rest using a Customer Managed Key (CMK), enforces encryption in transit (TLS) via bucket policy, and logs all access to a separate bucket.

## The problem
S3 bucket misconfigurations are the leading cause of cloud data breaches. Hardening S3 requires layered security controls, not just a single setting.

## What I built
- **Block Public Access:** Enforced at both the account and bucket levels.
- **SSE-KMS Encryption:** Customer Managed Key with annual rotation enabled.
- **Bucket Policy:** Explicitly denies any request that is not over TLS (`aws:SecureTransport: false`).
- **Access Logging:** Logs all read/write requests to a separate, encrypted logging bucket.
- **Lifecycle Rules:** Automatically expire non-current object versions after 30 days to save cost.

## Challenges
- **StringNotEqualsIfExists:** AWS CLI behavior differs across platforms. We used `StringNotEqualsIfExists` in the policy to enforce KMS encryption without breaking normal `aws s3 cp` commands that rely on default bucket encryption.

## Results
- Successfully blocked public access.
- Tested policy denial by attempting an unencrypted upload (AccessDenied).
- Cost: Under $0.50 for the duration of the project.