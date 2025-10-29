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

Deploy ConfigMaps, Deployment and Service:
   ```bash
   kubectl apply -f k8s/configmap-nginx.yaml
   kubectl apply -f k8s/configmap-lua.yaml
   kubectl apply -f k8s/deployment.yaml
   kubectl apply -f k8s/service.yaml


Create RBAC and CronJob:
   ```bash
   kubectl apply -f k8s/rbac.yaml
   kubectl apply -f k8s/cronjob-allowlist.yaml


Confirm:

kubectl -n webhook-gateway get pods,svc


In GitHub webhook settings (repo or organization):

Payload URL: https://webhooks.example.com/sonarqube (or /jenkins, /artifactory)

Content type: application/json

Secret: same HMAC secret (ex: REPLACE_ME_SONAR_SECRET)

Testing from a runner
payload='{"project":"myproj","status":"OK"}'
secret="REPLACE_ME_SONAR_SECRET"
sig=$(printf '%s' "$payload" | openssl dgst -sha256 -hmac "$secret" -binary | xxd -ps -c 256)
curl -v -X POST "https://webhooks.example.com/sonarqube" \
  -H "Content-Type: application/json" \
  -H "X-Hub-Signature-256: sha256=$sig" \
  -d "$payload"

Operational notes

CronJob refreshes GitHub hooks CIDRs every 6 hours. Adjust as needed.

Consider Azure Application Gateway (WAF) in front for additional filtering.

Use cert-manager or Azure Key Vault (CSI) for TLS cert automation.

Log X-GitHub-Delivery header for auditing and deduplication in backends.

Rotate HMAC secrets periodically.

Troubleshooting

403 from gateway: check allowlist.conf + HMAC secret mapping.

CronJob failing: verify ServiceAccount RBAC permissions.

Backend not receiving: check VPN/ExpressRoute connectivity and DNS resolution from AKS.
