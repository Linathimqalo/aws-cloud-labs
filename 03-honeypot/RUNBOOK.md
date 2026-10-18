# Runbook: AWS Honeypot

## Daily Operations
- Check Kibana dashboard once a day for new attack trends.
- Verify container health via SSM: `docker ps | wc -l` (should be ~41).
- Verify memory: `free -h`. Swap should be active.

## Troubleshooting
| Symptom | Cause | Fix |
|---------|-------|-----|
| Kibana won't load | Elasticsearch out of memory | Check `docker ps`. Restart tpot: `sudo systemctl restart tpot`. |
| Cannot access Kibana | Your home IP changed | Update `admin_cidr` in `terraform.tfvars` and run `terraform apply`. |
| T-Pot services crash | Instance ran out of disk space | T-Pot logs can fill 40GB. Check `df -h`. |

## Teardown
Do not leave the honeypot running indefinitely to avoid AWS bill shock.
1. Take final screenshots.
2. `terraform destroy`.