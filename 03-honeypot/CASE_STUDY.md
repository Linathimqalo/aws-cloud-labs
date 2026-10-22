# Case Study: AWS T-Pot Honeypot Threat Analysis

## Executive Summary
This project documents the deployment of a high-interaction T-Pot multi-honeypot on AWS EC2. The goal was to capture, analyze, and visualize real-world cyber attacks targeting cloud infrastructure. Over a 7-day period, the instance captured **363,000+ attacks**, including SSH brute force, RDP exploitation, and SIP scanning. The project required overcoming memory constraints via swap provisioning and hardening the security groups to isolate the administrative dashboard while exposing the honeypot services to the public internet.

## Architecture
- **Compute:** AWS EC2 `m7i-flex.large` (2 vCPU, 8GB RAM)
- **Operating System:** Ubuntu 24.04 LTS
- **Containers:** 41 Docker containers managed by the T-Pot framework (Cowrie, Dionaea, Honeytrap, Sentrypeer, etc.)
- **Storage:** 40GB gp3 EBS volume.
- **Network:** Deployed in the Public Subnet of a custom VPC.

## Security Design Decisions

**Decision 1: Separation of Attack and Admin Planes**
The security group exposes ports 1-64293 to `0.0.0.0/0` to capture attacks. However, administrative ports (64294-64300 for SSH, Cockpit, and Kibana) are strictly locked to the administrator's public IP (`/32` CIDR). This prevents attackers from pivoting from a compromised honeypot container into the management dashboard.

**Decision 2: Minimal IAM Role**
The EC2 instance is assigned an IAM role with only `AmazonSSMManagedInstanceCore`. If an attacker breaks out of a Docker container and achieves host-level code execution, their AWS privileges are null. They cannot access S3, Secrets Manager, or other AWS resources.

**Decision 3: Swap Provisioning for Stability**
T-Pot's 41 containers (specifically Elasticsearch and Kibana) exceeded the 8GB of RAM during high-volume attacks. Instead of upgrading the EC2 instance (increasing cost), we provisioned an 8GB swapfile with `vm.swappiness=10`. This prioritized RAM but allowed the system to survive traffic spikes without the Linux OOM killer terminating the logging pipeline.

## Threat Intelligence & Attack Metrics (Days 1-7)

### Volume
- **Total Attacks:** 363,000+ (in just 7 days).
- **Top Honeypots Triggered:** Sentrypeer (133k), Honeytrap (133k), Cowrie (33k), RDPHoneypot (28k), Mailoney (21k).
- **Top Targeted Ports:** 5060 (SIP), 3389 (RDP), 25 (SMTP), 23 (Telnet), 22 (SSH).

### Attacker Origins & Reputation
- **Top Source Countries:** Germany, The Netherlands, United States, Hong Kong, Poland.
- **Top Attacking ASNs:** Aiscyon B.V. (89,923 attacks), IONOS SE (47,086), Google LLC (10,890).
- **Top Attacking IPs:** 194.50.16.198 (87,608 attacks), 185.213.155.24 (32,872).

### Exploit Attempts (via Suricata)
- **CVE-2001-0540:** 26,358 attempts.
- **CAN-2001-0540:** 24,008 attempts.
- **CVE-2022-2725:** 1,105 attempts.
- **Alert Signatures:** ET INFO User-Agent (python-requests) Inbound to Webserver, GPL INFO VNC server response, ET EXPLOIT [PTsecurity] DoublePulsar Backdoor installation communication.

## Challenges and Remediation

**Challenge 1: T-Pot OS Compatibility**
T-Pot’s upstream installer required Ubuntu 26.04, but the latest AWS AMI was 24.04. The installer failed immediately.
- *Remediation:* Patched the `install.sh` script and the Ansible playbook (`tpot.yml`) to accept the version string "24.04" instead of "26.04". The containers ran perfectly.

**Challenge 2: The Silent OOM Killer**
Within 24 hours, Kibana became unresponsive. Investigation via `docker ps` showed Elasticsearch had restarted multiple times. The 8GB RAM was exhausted.
- *Remediation:* Created an 8GB swapfile, enabled it with `swapon`, and added it to `/etc/fstab`. Verified system stability under load.

## Key Lessons
1. **Cloud services are scanned instantly.** Automated SSH brute-force attempts began the moment the EC2 instance received a public IP.
2. **Memory is the silent bottleneck.** T-Pot looks lightweight, but Elasticsearch requires significant RAM. Swap is a mandatory safety net.
3. **Threat intelligence is actionable.** By analyzing the Kibana dashboards, we extracted actual ASNs and specific CVE exploit attempts, proving the honeypot successfully collected security data.

## Cost
- EC2 m7i-flex.large: ~$15.00 for 7 days.
- EBS 40GB: ~$0.67.
- Data transfer: ~$1.00.
- **Total: ~$16.67 for 7 days.**