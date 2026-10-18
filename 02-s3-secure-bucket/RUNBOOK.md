# Runbook: Secure S3 Bucket

## Incident Response: Data Leak
1. Immediately toggle "Block Public Access" to ON in the console if an accidental policy change occurred.
2. Review the `logs` bucket to see if any unauthorized GET requests occurred.
3. Rotate the KMS key if data was accessed by unauthorized entities.

## Common Failures
| Symptom | Cause | Fix |
|---------|-------|-----|
| Upload fails with AccessDenied | File uploaded without `--sse aws:kms` flag | Re-run the upload specifying the KMS encryption flag. |
| Cannot read object | IAM user lacks `kms:Decrypt` permission | Attach KMS decrypt permissions to the IAM user. |