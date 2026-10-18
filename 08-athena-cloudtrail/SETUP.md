# Setup: Athena

## Prerequisites
- Project 7 deployed (CloudTrail writing to S3).
- Terraform 1.5+

## Steps
1. Run `terraform init`, `plan`, and `apply`.
2. Go to the Athena Console.
3. Select the `athena-cloudtrail-workgroup`.
4. Select the `cloudtrail_db` database.
5. Run the SQL query from the README.

## Teardown
    terraform destroy