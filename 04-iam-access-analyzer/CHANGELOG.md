# Changelog

## 2026-10-16
- Initial Terraform for external access analyzer
- Initial Terraform for unused access analyzer
- Documentation templates created
- Apply successful: 2 analyzers active in eu-north-1
- ARNs:
  - external: arn:aws:access-analyzer:eu-north-1:106573904834:analyzer/iam-access-analyzer-external
  - unused: arn:aws:access-analyzer:eu-north-1:106573904834:analyzer/iam-access-analyzer-unused

## 2026-10-17
- Added console screenshots: analyzer list, summary page
- First-scan still populating ("Check back later" message)
- Expecting findings in the next 24 hours

## Observations
- First scan takes 1-24 hours to populate. Console shows
  "Check back later to view the summary" until then.
- No findings expected: account has no cross-account resource
  policies and only one active IAM user.