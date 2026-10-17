# AWS Cloud Engineering & Security Portfolio

This repository contains a series of production-style AWS projects built with Terraform. 

Each project includes full documentation (architecture, security decisions, setup, and runbooks), proving not just the ability to deploy cloud infrastructure, but to secure, operate, and document it.

## Projects

1. **[VPC Three-Tier Architecture](./01-vpc-three-tier/)** - Custom VPC, subnets, IGW, and Flow Logs.
2. **[S3 Secure Bucket](./02-s3-secure-bucket/)** - KMS encryption, deny policies, and logging.
3. **[T-Pot Honeypot](./03-honeypot/)** - Threat detection and attack analysis on EC2.
4. **[IAM Access Analyzer](./04-iam-access-analyzer/)** - Continuous policy drift and unused access detection.
5. **[Lambda + S3 + IAM](./05-lambda-s3-iam/)** - Event-driven serverless pipeline with least privilege.
6. **[EC2 + RDS Three-Tier](./06-ec2-rds-three-tier/)** - Private database, Secrets Manager, and SSM access.

## Skills Demonstrated
- **Infrastructure as Code:** Terraform, AWS CLI
- **Networking:** VPC design, Security Groups, Route Tables
- **Security:** Least Privilege IAM, KMS, Secrets Manager, SSM (no SSH)
- **Compute & Storage:** EC2, Lambda, S3, DynamoDB, RDS
- **Operations:** CloudWatch, VPC Flow Logs, incident response runbooks