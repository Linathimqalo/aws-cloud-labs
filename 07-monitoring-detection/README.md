# Project 7: Monitoring & Detection

## What this is
A centralized security monitoring and alerting pipeline. AWS CloudTrail logs all API activity, while GuardDuty analyzes logs for malicious behavior. Any threat detected by GuardDuty is routed via EventBridge to an SNS topic, which sends an email alert. 

## Why this matters in a real job
You cannot secure what you cannot see. Every enterprise AWS environment relies on CloudTrail and GuardDuty. Understanding how to wire these services together, filter the noise, and route alerts to the right teams is the foundation of Security Operations (SecOps).

## Architecture
[ AWS Activity ] --> [ CloudTrail ] --> [ S3 Bucket ]
                           |
[ VPC/DNS Logs ] --> [ GuardDuty ] --> [ EventBridge ] --> [ SNS ] --> [ Email ]

## Design decisions and tradeoffs
| Decision | Alternative | Why we chose this |
|----------|-------------|-------------------|
| CloudTrail to S3 | CloudWatch Logs only | S3 is cheaper for long-term storage and immutable. CloudWatch is for real-time metric filters. |
| EventBridge to SNS | CloudWatch Alarms | EventBridge is event-driven and easily parses structured GuardDuty JSON findings. |
| Log file validation | None | Ensures logs haven't been tampered with (compliance requirement). |
| 15-min GuardDuty publishing | 6 hours (default) | 15 minutes allows for faster incident response. Costs are negligible for small accounts. |

## Common failure modes
- **No email received:** You forgot to click the "Confirm subscription" link in the first SNS email.
- **No GuardDuty findings:** GuardDuty takes 24-48 hours to establish a baseline in a new account before it starts flagging anomalies.
- **CloudTrail creation failed:** The S3 bucket policy wasn't applied before the trail creation. Terraform `depends_on` handles this.