# Setup: Monitoring & Detection

## Prerequisites
- Terraform 1.5+
- AWS CLI configured

## Steps

1. Create the folder and files.
2. Initialize and apply:
       terraform init
       terraform plan -out=tfplan
       terraform apply tfplan

3. **CRITICAL:** Check your email inbox. 
   You will receive an email from `no-reply@sns.amazonaws.com` with the subject "AWS Notification - Subscription Confirmation".
   Click the **Confirm subscription** link.

## Verification
1. Check CloudTrail is logging:
   Console -> CloudTrail -> Trails -> `monitoring-detection-trail` -> shows "Logging: On".
2. Check GuardDuty is enabled:
   Console -> GuardDuty -> Summary. Shows active.

## Teardown
    terraform destroy