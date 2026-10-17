# Runbook: EC2 + RDS Three-Tier

## Normal operations
- EC2 runs nginx (port 80) proxying to Flask (port 5000).
- Flask connects to RDS PostgreSQL on port 5432.
- Health can be checked by sending an HTTP GET to the public IP.

## Health checks

1. Check Flask app from inside the instance:
       curl http://localhost:5000

2. Check systemd service:
       sudo systemctl status flaskapp

3. Check nginx:
       sudo systemctl status nginx

4. Check DB connection:
       psql -h <db_endpoint> -U dbadmin -d appdb
       (Password is in Secrets Manager).

## Common troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| HTTP 502 Bad Gateway | Flask app is not running or still starting | Wait 3 mins after boot, check `journalctl -u flaskapp`. |
| DB connection timeout | Security group misconfigured or wrong endpoint | Verify `db-sg` allows 5432 from `app-sg`. Check RDS endpoint in Secrets Manager. |
| App fails at boot | Secrets Manager permission denied | Check IAM role attached to EC2. Verify `secretsmanager:GetSecretValue`. |
| Can't reach EC2 URL | App SG missing port 80 rule, or instance not public | Check `app-sg` and ensure EC2 is in public subnet with public IP. |

## Incident Response: Unauthorized Access
If the app is compromised:
1. Isolate the instance: Change `app-sg` to remove port 80 ingress.
2. Use SSM to inspect logs: `sudo journalctl -u flaskapp` and `/var/log/nginx/access.log`.
3. Check CloudTrail for unusual IAM role usage by the instance.

## Teardown
Run `terraform destroy` from the project directory.