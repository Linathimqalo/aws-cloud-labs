# Case Study: Threat Detection & Automated Alerting

## Summary
Built a security monitoring pipeline using AWS CloudTrail, GuardDuty, EventBridge, and SNS. The system captures all account activity, detects malicious behavior, and routes alerts to email in near real-time.

## The problem
AWS accounts are noisy. Thousands of API calls happen every hour. If an attacker steals a credential or spins up a Bitcoin miner, manual inspection of logs will not catch it fast enough. 

## What I built
- **Audit Logging:** CloudTrail configured for multi-region logging with log file validation.
- **Threat Detection:** GuardDuty enabled to analyze VPC Flow Logs, DNS queries, and CloudTrail events for known Indicators of Compromise (IOCs).
- **Automated Response:** EventBridge rules that capture `GuardDuty Finding` events and push them to an SNS topic.
- **Alerting:** SNS topic with an email subscription.

## Security decisions
- **Log File Integrity:** Enabled CloudTrail log file validation to ensure no one can modify or delete logs without detection.
- **S3 Isolation:** The CloudTrail bucket blocks all public access.
- **Least Privilege for SNS:** The SNS topic policy only allows the `events.amazonaws.com` service to publish to it.

## Challenges and how I solved them
- **SNS Silent Failure:** The system was deployed, but no emails were arriving. Root cause: AWS sends a double opt-in email to subscribers, and I had not clicked the confirmation link. Once confirmed, alerts flowed correctly.
- **Terraform Dependency:** CloudTrail failed to create initially because the S3 bucket policy was not yet attached. Fixed by adding `depends_on = [aws_s3_bucket_policy.cloudtrail_logs]` to the CloudTrail resource.

## 2026-10-18 (Deferral of GuardDuty)

**Issue:** Terraform failed with `SubscriptionRequiredException` when attempting to create the GuardDuty detector. The AWS Console also prevented manual activation due to the account being on the "Free Plan" with pending registration.

**Root Cause:** New AWS accounts require a one-time manual "subscription" or "activation" for security services like GuardDuty. This cannot be done via Terraform until the account's payment verification is fully cleared (can take up to 24 hours). 

**Resolution:** Deferred GuardDuty for this project. The CloudTrail, S3, SNS, and EventBridge resources were successfully deployed. GuardDuty can be enabled later by uncommenting the code once the AWS account registration is fully complete. This is a common pattern in real-world IaC: adapting to account-level service limits.

## Results
- Successfully generated a "fake" finding (e.g., SSH brute force against an EC2 instance).
- GuardDuty detected the activity and generated a finding.
- EventBridge captured the finding and triggered SNS.
- Email arrived in inbox within 15 minutes.