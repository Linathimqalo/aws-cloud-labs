# Setup: AWS Honeypot

## Prerequisites
- Project 1 VPC deployed.
- Your home public IP address.

## Steps
1. Navigate to folder: `cd 03-honeypot`
2. `terraform init`, `plan -out=tfplan`, `apply tfplan`
3. Wait 3 minutes for EC2 to boot.
4. Connect via AWS Systems Manager (Session Manager).
5. Run the T-Pot installation (detailed in the README).

## Post-Install
Reboot the instance via SSM. Wait 3 minutes, then access Kibana at `https://<public-ip>:64297`.

## Teardown
    terraform destroy