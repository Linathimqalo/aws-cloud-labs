# Changelog

## 2026-10-17 (Initial Deployment)

- Deployed 13 resources (VPC reuse, EC2, RDS, IAM, Secrets Manager).
- **Issue 1:** RDS creation failed with `InvalidParameterCombination: Cannot find version 16.3 for postgres`. 
  - *Root cause:* AWS RDS deprecated PostgreSQL 16.3 in eu-north-1.
    Minor versions are removed from the createable pool after their support window ends. Pinning an exact minor version (16.3) breaks on re-deploy once AWS rotates it out.

  - *Fix:* Changed `engine_version` from `"16.3"` to `"16"` (major version only). AWS selects the current supported minor version automatically.
  - *Learning:* Never pin an exact RDS minor version in Terraform unless you have a specific reason. Major version pinning is safer. Exact minor pinning creates time bombs in your codebase.

- **Issue 2:** The second apply forced the EC2 instance to be replaced because the `data "aws_ami"` block fetched a newer Amazon Linux 2023 AMI.
  - *Root cause:* The AMI filter uses `most_recent = true`. When AWS released a new AMI, Terraform detected drift and forced replacement.
  - *Fix:* No fix needed for a lab. In production, you would pin the exact AMI ID or use a launch template to control updates.
- **Result:** `terraform apply` completed. RDS took 5m11s to provision.
- **Testing:** `curl` to EC2 public IP returned successful JSON from the PostgreSQL database. SSM access confirmed working without SSH keys.

- **Issue 3:** `user_data` script continued to fail with `could not translate host name "$DB_HOST"` even after updating the script to use `boto3`.
  - *Root cause:* Terraform's default behavior for `user_data` is to update the EC2 metadata in place. It does **not** reboot the instance or re-run the script. 
  - *Attempted Fix:* Added `user_data_replace_on_change = true` to the EC2 resource. However, the first apply only flipped the flag from `false` to `true` in the state, it did not actually replace the instance.
  - *Final Fix:* Ran `terraform apply -replace="aws_instance.app_server" -auto-approve`. This explicitly forced Terraform to destroy the instance and build a fresh one, triggering the `user_data` script on first boot.
  - *Result:* App successfully connected to RDS. `curl` returned `{"message":"Connected to PostgreSQL","status":"success","total_visits":3}`.