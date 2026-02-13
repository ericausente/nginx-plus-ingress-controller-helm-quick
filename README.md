# NGINX Plus Ingress Controller – Helm Quick Install

This repository provides a simple automation script to install  
**F5 NGINX Ingress Controller with NGINX Plus** using Helm.

---

## Requirements

- Active NGINX Plus subscription (JWT required)
- Kubernetes cluster (supported version)
- Helm 3.19+
- kubectl configured to target your cluster

---

## Download Your JWT

1. Log in to MyF5.
2. Navigate to **My Products & Plans → Subscriptions**.
3. Select your NGINX subscription.
4. Download the `license.jwt` file.

⚠️ JWT files are sensitive. Store securely and delete after installation.

---

## Installation

Make the script executable:

chmod +x install-nginx-plus-nic.sh

You will be prompted for:
	•	Namespace (default: nginx-ingress)
	•	Release name (default: nginx-plus)
	•	Path to your license.jwt

⸻

What This Script Does
	•	Creates Kubernetes namespace (if missing)
	•	Creates:
	•	nplus-license secret
	•	regcred docker registry secret
	•	Installs NGINX Plus Ingress Controller via Helm
	•	Verifies deployment

⸻

Verify Deployment

Check pods:
```
kubectl -n nginx-ingress get pods
```
Check ingress classes:
```
kubectl get ingressclasses
```

You should see:
```
nginx
```

Helm Values Used
```
--set controller.image.repository=private-registry.nginx.com/nginx-ic/nginx-plus-ingress
--set controller.image.tag=5.3.3
--set controller.nginxplus=true
--set controller.serviceAccount.imagePullSecretName=regcred
--set controller.mgmt.licenseTokenSecretName=nplus-license
```
Production Notes
	•	Do NOT use 0.0.0-edge in production.
	•	Consider setting:
	•	replicaCount > 1
	•	PodDisruptionBudget
	•	resource limits
	•	NodeSelector / Tolerations
	•	Service type LoadBalancer or NodePort as required

⸻

Cleanup

To uninstall:
```
helm uninstall nginx-plus -n nginx-ingress
kubectl delete ns nginx-ingress
```
