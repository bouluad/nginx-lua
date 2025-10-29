# NGINX Webhook Proxy for GitHub → On-Premise Tools

This project provides a secure NGINX-based proxy that receives GitHub webhooks in Azure (AKS) and forwards them to on-premise tools like Jenkins, SonarQube, and Artifactory.

## 🧩 Architecture Overview
1. GitHub sends webhooks to a public endpoint in AKS.
2. NGINX validates the source IP against allowed GitHub IPs.
3. Requests are securely routed to the correct on-premise service based on the path.

Example:
- `/webhook/jenkins` → On-prem Jenkins 1 or 2
- `/webhook/sonarqube` → On-prem SonarQube
- `/webhook/artifactory` → On-prem Artifactory

---

## 🛡️ Security
- Only GitHub IP ranges are allowed.
- TLS termination is handled by Ingress Controller.
- Each backend can be protected using mutual TLS (optional).

---

## 🚀 Deployment Steps

### 1. Build NGINX ConfigMap
```bash
kubectl apply -f nginx-configmap.yaml
```

### 2. Deploy NGINX Deployment and Service
```bash
kubectl apply -f nginx-deployment.yaml
```

### 3. Deploy Ingress Controller
```bash
kubectl apply -f nginx-ingress.yaml
```

---

## 🧪 Testing
Simulate a webhook call:
```bash
curl -X POST https://your-proxy.example.com/webhook/sonarqube -d '{"test":"ok"}' -H "Content-Type: application/json"
```

---

## 🧰 Files
- `nginx-configmap.yaml` → Routing logic
- `nginx-deployment.yaml` → NGINX pod definition
- `nginx-ingress.yaml` → Public ingress
- `nginx.conf` → Custom NGINX configuration
- `README.md` → This file
