# Case Study: VPC Three-Tier Architecture

## Summary
Designed and deployed a production-grade VPC foundation across two Availability Zones in AWS. The architecture provides strict network isolation between public-facing services, private application servers, and private database subnets.

## The problem
Default VPCs are flat networks where everything can talk to everything else. In a real production environment, a compromised web server should not have direct access to the database. Network segmentation is a fundamental security requirement.

## What I built
- Custom VPC (10.0.0.0/16) in eu-north-1.
- 6 subnets across 2 AZs: 2 Public, 2 Private App, 2 Private Data.
- Internet Gateway (IGW) for public internet access.
- Per-tier Route Tables.
- S3 Gateway Endpoint (allows private subnets to reach S3 without a costly NAT Gateway).
- VPC Flow Logs routed to CloudWatch for network auditing.

## Design decisions
- **No NAT Gateway:** NAT Gateways cost ~$32/month. By using a Gateway Endpoint, we saved this cost while still allowing private instances to access S3.
- **Multi-AZ:** Subnets are spread across eu-north-1a and eu-north-1b to ensure high availability.
- **Segregated Route Tables:** Public subnets route to the IGW; private subnets have no direct internet route.

## Results
- Deployed 22 resources in 45 seconds via Terraform.
- Verified network isolation and route table associations.
- Cost: $0.00 (All components fall within AWS Free Tier limits).