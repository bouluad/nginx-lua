# AKS Nginx Webhook Gateway

This deploys an OpenResty (Nginx + Lua) webhook gateway in AKS to receive GitHub Enterprise webhooks and forward them securely to on-prem services (SonarQube, Artifactory, Jenkins).

## Features
- HMAC SHA256 verification (X-Hub-Signature-256)
- GitHub hooks IP allowlist (auto-updated via CronJob)
- TLS termination (secret `webhook-tls`)
- Rate limiting and basic DoS protection
- Header-based dynamic routing for multiple Jenkins instances

## Prerequisites
- AKS cluster with subnet `tds2` and connectivity to on-prem via VPN / ExpressRoute
- A reserved static Public IP in the same Azure region / resource group
- DNS record (e.g. `webhooks.example.com`) pointing to the public IP
- `kubectl` configured for the cluster
- `jq` available in CronJob image (the provided bitnami/kubectl image includes `jq`)
- Secrets: HMAC per backend and optional GitHub token (to avoid API rate limits)

## Quick deploy
1. Edit all `REPLACE_ME_*` placeholders in `k8s/*.yaml` and `nginx/nginx.conf`.
2. Create namespace and secrets:
   ```bash
   kubectl apply -f k8s/namespace.yaml
   kubectl apply -f k8s/secrets.yaml
