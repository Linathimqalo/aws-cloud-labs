# Setup: IAM Access Analyzer

## Prerequisites
- AWS CLI configured with an admin user
- Terraform 1.5+
- Region eu-north-1

## Steps

    cd 04-iam-access-analyzer
    terraform fmt
    terraform init
    terraform validate
    terraform plan -out=tfplan
    terraform apply tfplan

## Verification checklist
- [x] Console: IAM -> Access Analyzer -> both analyzers listed
- [x] External analyzer status: Active
- [x] Unused analyzer status: Active, configuration shows 90-day window
- [x] Findings tab: "Check back later" for first 24 hours
- [ ] After 24 hours: confirm findings displayed (expected: zero)

## Common errors
(Tracked in CHANGELOG.)

## Customization
- Change `unused_access_age` for stricter or looser reviews
- Add organization-level analyzer if you join AWS Organizations

## Teardown
    terraform destroy