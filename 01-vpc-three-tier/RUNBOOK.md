# Runbook: VPC Three-Tier

## Normal Operations
VPC is infrastructure-only. No compute resources are running by default.

## Troubleshooting
| Symptom | Cause | Fix |
|---------|-------|-----|
| Private EC2 cannot reach S3 | Route table missing endpoint | Check that the S3 Gateway Endpoint is attached to the private route tables. |
| Cannot connect to the internet from public subnet | IGW missing or detached | Check Route Table for `0.0.0.0/0` pointing to `igw-xxx`. |

## Teardown
Destroying the VPC will fail if any EC2 instances or RDS databases still exist inside it. Delete downstream projects first.