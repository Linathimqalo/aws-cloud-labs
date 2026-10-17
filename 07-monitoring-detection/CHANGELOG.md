# Changelog

## 2026-10-18
- Initial Terraform created for CloudTrail, GuardDuty, SNS, and EventBridge.
- Configured CloudTrail to log to a secure, encrypted S3 bucket with log file validation.
- Enabled GuardDuty with a 15-minute publishing frequency.
- Set up EventBridge rule to route GuardDuty findings to an SNS topic.
- Added SNS email subscription for real-time alerting.

## 2026-10-18 (Deferral of GuardDuty)

**Issue:** Terraform failed with `SubscriptionRequiredException` when attempting to create the GuardDuty detector. The AWS Console also prevented manual activation due to the account being on the "Free Plan" with pending registration.

**Root Cause:** New AWS accounts require a one-time manual "subscription" or "activation" for security services like GuardDuty. This cannot be done via Terraform until the account's payment verification is fully cleared (can take up to 24 hours). 

**Resolution:** Deferred GuardDuty for this project. The CloudTrail, S3, SNS, and EventBridge resources were successfully deployed. GuardDuty can be enabled later by uncommenting the code once the AWS account registration is fully complete. This is a common pattern in real-world IaC: adapting to account-level service limits.