# Project 1: VPC Three-Tier Architecture

Deployed a production-style VPC on AWS with Terraform.

## Architecture

- VPC 10.0.0.0/16 in eu-north-1 (Stockholm)
- 2 public subnets (10.0.1.0/24, 10.0.2.0/24) across 2 AZs
- 2 private app subnets (10.0.11.0/24, 10.0.12.0/24) across 2 AZs
- 2 data subnets (10.0.21.0/24, 10.0.22.0/24) across 2 AZs
- Internet Gateway for public subnets
- Per-tier route tables
- S3 Gateway Endpoint for private and data subnets
- VPC Flow Logs to CloudWatch (7 day retention)

## Design choices

- **No NAT Gateway yet.** Would cost about $32/month. VPC Endpoint
  covers S3 access from private subnets. NAT can be added later if
  outbound internet is needed.
- **Two AZs.** Real availability zone redundancy, not just same-AZ.
- **Separate route table per tier.** Public routes to IGW. Private
  and data route to S3 endpoint only. No internet path.
- **Default tags on all resources.** Project, Environment, ManagedBy,
  Owner. Easier billing, easier cleanup.

## Cost

Flow Logs to CloudWatch: under $0.50/month for low traffic volume.
Everything else is Free Tier or free.

## Usage

    cd 01-vpc-three-tier
    terraform init
    terraform plan
    terraform apply

To tear down:

    terraform destroy

## What I learned

- (fill in after deployment)

## Screenshots

- (add console screenshots after apply)