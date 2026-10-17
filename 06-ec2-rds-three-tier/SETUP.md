# Setup: EC2 + RDS Three-Tier

## Prerequisites
- Project 1 VPC deployed (requires VPC ID and Subnet IDs).
- Terraform 1.5+
- AWS CLI configured with admin access.

## Steps

1. Create the folder structure:
       mkdir -p 06-ec2-rds-three-tier
       cd 06-ec2-rds-three-tier

2. Create the Terraform files and scripts.

3. Copy the tfvars example:
       cp terraform.tfvars.example terraform.tfvars

4. Edit `terraform.tfvars` and fill in the IDs from Project 1.

5. Deploy:
       terraform fmt
       terraform init
       terraform validate
       terraform plan -out=tfplan
       terraform apply tfplan

## Verification

1. **Wait 3 minutes** after apply completes for the `user_data` script to finish.

2. Test the application:
       curl http://<app_server_public_ip>
   (Should return a JSON success message).

3. Test DB isolation:
       nc -zv <db_endpoint> 5432
   (Should refuse connection).

4. Connect via SSM:
   - Console -> EC2 -> Instance -> Connect -> Session Manager.
   - `sudo su - ec2-user`
   - `sudo journalctl -u flaskapp.service`

## Teardown

    terraform destroy

**Important:** RDS takes time to delete. Do not interrupt the destroy command.