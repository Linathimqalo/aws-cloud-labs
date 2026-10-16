# Case Study: Enabling IAM Access Analyzer for External Access Detection

## Summary
Enabled account-level IAM Access Analyzer to continuously detect
resources shared outside the AWS account. Establishes a baseline
of zero unauthorized external access and a review workflow for
future findings.

## The problem
IAM policies and resource policies can accidentally grant access
to entities outside the AWS account. Common causes: S3 buckets
with wildcard principals, KMS key policies with cross-account
access, IAM roles with trust policies pointing to unknown
accounts. Manual IAM review does not scale beyond a few dozen
resources.

## What I built
- Two Terraform-managed IAM Access Analyzers (account level)
- External access analyzer to detect cross-account resource sharing
- Unused access analyzer with 90-day window to support least privilege

## Architecture
Account-level analyzers, continuously scanning resource policies
and IAM activity.

## Security decisions
- External access analyzer catches the highest-risk class of
  finding: resources visible outside the account boundary
- Unused access analyzer supports the least-privilege principle
  by identifying permissions that are no longer needed
- Both analyzers are free, no cost tradeoff for enabling

## Challenges and how I solved them

**First-scan latency.** AWS Access Analyzer does not return findings
immediately. The console shows "Check back later to view the summary"
until the initial scan completes (up to 24 hours). This is not a
failure, it is service behavior. Documented for future expectations.

**Choosing the right analyzer type.** AWS offers three analyzer
types: ACCOUNT, ORGANIZATION, and ACCOUNT_UNUSED_ACCESS. I selected
ACCOUNT for external findings and ACCOUNT_UNUSED_ACCESS with a
90-day window for unused permissions. ORGANIZATION was not applicable
because the account is not part of AWS Organizations.

## Results

- 2 analyzers deployed in under 10 seconds total
- Zero external findings: account has no cross-account resource policies
- Zero unused access findings: account is small, all permissions in daily use
- Continuous monitoring active: any future cross-account policy change
  will surface as a finding within hours
- Cost: $0.00 (both analyzer types are free)

## Skills demonstrated
- IAM policy analysis
- AWS native security tooling
- Terraform infrastructure as code
- Account-level security baseline

## What I would do differently
(To be filled in.)

## Links
GitHub: /03-.../04-iam-access-analyzer

## About
Cloud security and infrastructure engineer building practical
skills in AWS, Terraform, and detection engineering.