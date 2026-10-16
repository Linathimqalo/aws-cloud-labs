# Project 4: IAM Access Analyzer

## What this is
IAM Access Analyzer is an AWS native service that continuously
monitors your account for resources shared with external entities
and identifies unused permissions. It surfaces findings that are
otherwise invisible without manual IAM policy review.

## Why this matters in a real job
- Detects S3 buckets, IAM roles, KMS keys, Lambda functions, and
  SQS queues that grant access to accounts outside your organization
- Identifies IAM users, roles, and permissions that have not been
  used in a defined window, supporting least-privilege cleanup
- Findings integrate with Security Hub and EventBridge for automated
  response
- Common in compliance audits (SOC 2, ISO 27001, PCI DSS)
- Zero cost for the account-level analyzer, making it a default
  enablement in mature AWS accounts

## Architecture
Account-level analyzers, no VPC or network dependency.
Both analyzers continuously scan resource policies.

## Design decisions and tradeoffs

| Decision | Alternative | Why we chose this |
|----------|-------------|-------------------|
| Account-level analyzer | Organization-level | We have one account. Org level requires AWS Organizations. |
| Unused access age = 90 days | 30, 180, 365 | 90 days matches AWS recommendation and quarterly review cycles |
| Default tags on analyzers | No tags | Enables cost/scope filtering even though analyzers are free |

## Security posture
- Analyzer itself has no resources to attack
- Findings are read-only; no ability to modify your account
- IAM role is managed by AWS; no customer-managed role needed

## Cost model
- Account-level external analyzer: free
- Account-level unused access analyzer: free
- No per-finding charge for either

## Common failure modes
- Findings require resources to exist; a fresh account will show zero
- Unused access analyzer requires 90+ days of IAM activity to be useful
- Findings that are marked as "resolved" return if the policy changes back

## What I learned

- Access Analyzer has three scopes: ACCOUNT, ORGANIZATION, and
  UNUSED_ACCESS. The naming is not intuitive; the UNUSED_ACCESS
  type is configured with a separate `configuration` block.
- Findings take time to appear. A clean account returns no findings,
  which is not the same as "service broken."
- Both analyzers are free. Unlike most security services, there is
  no cost tradeoff for enabling them. This makes them safe defaults.
- The unused access analyzer replaces manual "who has not logged in"
  reports. It tracks role assumptions and permission usage, not just
  user logins.

## Related services
- AWS IAM Access Analyzer policy validation (linter for policies)
- AWS Security Hub (aggregates findings)
- AWS EventBridge (automated response triggers)
- AWS Config (checks IAM policies against rules)

## Teardown
    terraform destroy