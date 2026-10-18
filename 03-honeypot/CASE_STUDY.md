# Case Study: AWS Honeypot Deployment (T-Pot)

## Summary
Deployed a T-Pot multi-honeypot on an AWS EC2 instance to capture, analyze, and visualize real-world cyber attacks. This project generates live threat intelligence and demonstrates the ability to build and operate security monitoring infrastructure.

## The problem
Security teams need to understand attacker behavior to build defenses. Honeypots are fake targets that log every interaction, providing raw data on brute-force attacks, malware delivery, and scanning patterns.

## What I built
- **EC2 Instance:** m7i-flex.large (8GB RAM) running Ubuntu 24.04.
- **T-Pot Framework:** 41 Docker containers representing various vulnerable services (SSH, HTTP, SMB, RDP, etc.).
- **Network Isolation:** Deployed in a public subnet with a strict Security Group allowing admin access only from my home IP, while leaving honeypot ports exposed to the internet.
- **Access Management:** No SSH keys. Connected exclusively via AWS Systems Manager (SSM).
- **Performance:** Added 8GB of swap to handle memory pressure from 41 containers.

## Challenges
- **T-Pot OS Restrictions:** Upstream T-Pot only supports Ubuntu 26.04. We patched the installation script and Ansible playbook to accept 24.04.
- **Memory Exhaustion:** T-Pot uses significant RAM. Without swap, the OOM killer was terminating Elasticsearch. Added an 8GB swapfile and configured `vm.swappiness=10`.

## Results
- Deployed successfully and captured [Insert Total Attacks] attacks over 7 days.
- Generated valuable data for comparison against GCP and Azure honeypot deployments.
- Cost: ~$16 for 7 days of compute and data transfer.