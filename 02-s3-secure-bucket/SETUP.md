# Setup: S3 Secure Bucket

## Steps
1. Navigate to folder: `cd 02-s3-secure-bucket`
2. `terraform init`, `plan -out=tfplan`, `apply tfplan`
3. Note the outputs (`main_bucket_name` and `kms_key_alias`).

## Verification
1. Console -> S3 -> Click the main bucket.
2. Check Properties: Verify Versioning is Enabled and Default Encryption is AWS-KMS.
3. Check Permissions: Verify Block Public Access is On.
4. CLI Test: Try uploading a file without encryption:
   `aws s3 cp test.txt s3://<bucket>/test.txt` (Should fail).
5. CLI Test: Upload with encryption:
   `aws s3 cp test.txt s3://<bucket>/test.txt --sse aws:kms` (Should succeed).

## Teardown
    terraform destroy
    (Note: KMS keys take 7 days to fully delete after destroy).