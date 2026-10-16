# Setup: Lambda + S3 + IAM

## Prerequisites
- AWS CLI configured with admin user
- Terraform 1.5+
- Python 3.12 (for local syntax check only; Lambda runs its own)
- Region: eu-north-1

## Steps

    cd 05-lambda-s3-iam
    terraform fmt
    terraform init
    terraform validate
    terraform plan -out=tfplan
    terraform apply tfplan

## Verification

1. S3 bucket created:
       aws s3 ls | grep linathi-lambda-lab

2. Upload a test file:
       echo "test content" > test.txt
       aws s3 cp test.txt s3://<bucket-name>/test.txt

3. Wait 5 seconds, then check DynamoDB:
       aws dynamodb scan --table-name lambda-s3-iam-file-metadata

4. Check CloudWatch Logs:
       aws logs tail /aws/lambda/lambda-s3-iam-process-upload --since 5m

5. Screenshot console views:
   - S3 bucket with object
   - Lambda function details
   - IAM role policy JSON
   - DynamoDB table with record
   - CloudWatch log stream

## Common errors
(Track in CHANGELOG.)

## Teardown

    terraform destroy