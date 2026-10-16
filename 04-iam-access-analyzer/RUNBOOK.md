# Runbook: IAM Access Analyzer

## Normal operations
Two analyzers active. Findings reviewed weekly.

## Health checks

    aws accessanalyzer list-analyzers --region eu-north-1

Expected: two analyzers with status ACTIVE.

## Alerts and alarms
No CloudWatch alarms by default. Add SNS to route findings to email
for production use.

## Incident response
For each finding:
1. Identify the resource via ARN
2. Confirm whether the external access is intentional
3. If unintentional: remove the resource policy statement
4. Mark finding as Archived with a note
5. Document in CHANGELOG

## Common troubleshooting
| Symptom | Cause | Fix |
|---------|-------|-----|
| No findings | No external-access policies exist | Expected in a clean account |
| Unused analyzer shows no data | Insufficient activity window | Wait 90 days or lower age threshold |
| Finding persists after fix | Policy not updated | Re-check bucket policy or IAM role |

## Escalation
For production: route findings to a Slack channel via EventBridge +
Lambda. Alert on severity HIGH.

## Recovery
Findings are non-destructive; no recovery needed. If the analyzer
is deleted accidentally, re-apply Terraform.