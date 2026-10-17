# Runbook: Monitoring & Detection

## Normal operations
- CloudTrail logs every API call to S3.
- GuardDuty silently monitors the account.
- SNS sits idle unless a finding is generated.

## Incident Response: GuardDuty Alert
When you receive an email from SNS containing a GuardDuty finding:
1. **Do not panic.** Many findings are "Low" severity (e.g., port scanning from the outside).
2. Log in to the AWS Console and go to GuardDuty.
3. Click on the specific finding to read the details. Look at the "Action" tab.
4. If the finding indicates a compromised IAM key (e.g., `UnauthorizedAccess:IAMUser`), immediately deactivate that user's access keys.
5. If it indicates a compromised EC2 instance (e.g., `CryptoCurrency:EC2`), isolate the instance by removing its security group.

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| No emails from SNS | Subscription not confirmed | Check email, click confirmation link. |
| Finding shows but no email | EventBridge rule misconfigured | Check EventBridge -> Rules -> Event Pattern matches `source: aws.guardduty`. |
| High bill from GuardDuty | You are past the 30-day trial | Destroy the GuardDuty detector via Terraform. |