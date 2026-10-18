# Setup: VPC Three-Tier

## Prerequisites
- Terraform 1.5+
- AWS CLI configured

## Steps
1. Navigate to the folder: `cd 01-vpc-three-tier`
2. Initialize Terraform: `terraform init`
3. Review the plan: `terraform plan -out=tfplan`
4. Apply: `terraform apply tfplan`

## Verification
1. AWS Console -> VPC -> Your VPCs. Confirm `vpc-three-tier-vpc` exists.
2. Check Subnets: Confirm 6 subnets exist with correct CIDR blocks.
3. Check Route Tables: Ensure the public route table has a route to the IGW, and private route tables do not.

## Teardown
    terraform destroy