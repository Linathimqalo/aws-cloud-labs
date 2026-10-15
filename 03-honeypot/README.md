# Project 3: T-Pot Honeypot on AWS EC2

Deployed T-Pot (multi-honeypot platform) on AWS EC2 to capture
real-world attacks and compare AWS behavior against GCP and Azure
honeypot deployments from earlier work.

## Architecture

- EC2 m7i-flex.large (2 vCPU, 8GB RAM) in eu-north-1a
- Ubuntu 24.04 LTS
- Public subnet of `vpc-three-tier-vpc` (reused from Project 1)
- Security group `honeypot-sg`
- IAM role `honeypot-ssm-role` for SSM Session Manager access
- No SSH key required (SSM only)

## Security group design

| Port | Direction | Source | Purpose |
|------|-----------|--------|---------|
| 1-64293 TCP | Ingress | 0.0.0.0/0 | Honeypot attack surface |
| 1-64293 UDP | Ingress | 0.0.0.0/0 | Honeypot attack surface |
| 64294 TCP | Ingress | admin only | Cockpit |
| 64295 TCP | Ingress | admin only | SSH (T-Pot shifted) |
| 64297 TCP | Ingress | admin only | NGINX / Kibana |

## Deployment notes

- T-Pot upstream targets Ubuntu 26.04. Patched `install.sh` line 325
  and `installer/install/tpot.yml` line 120 to accept 24.04.
  Functionally compatible; containers use standard Docker base images.
- Added 8GB swapfile because the running container count (41) exceeds
  available RAM (7.6GB). `vm.swappiness=10` to prefer RAM.
- Kibana reachable at `https://<honeypot-ip>:64297` from admin IP only.

## What I learned

- T-Pot's upstream version gate rejects Ubuntu 24.04 despite it
  working fine. Patched two files to allow it.
- 41 containers is more than the classic T-Pot footprint. Memory
  pressure is real; swap is mandatory.
- SSM Session Manager works well for zero-key access. No SSH key,
  no bastion, no open port 22.

## Findings

(Filled in after 7 days.)

## Cost

- EC2 m7i-flex.large: ~$15.60 over 7 days
- EBS 40GB gp3: ~$0.67
- Data transfer out: $0-$7 depending on attack volume
- Total: $16-$23

## Teardown

    cd 03-honeypot
    terraform destroy

## Comparison with GCP and Azure

(To be filled in.)