#!/usr/bin/env bash

set -e

echo "=============================================="
echo "NGINX Plus Ingress Controller Installer"
echo "=============================================="

# ---- Prerequisite checks ----
command -v kubectl >/dev/null 2>&1 || { echo "kubectl not found"; exit 1; }
command -v helm >/dev/null 2>&1 || { echo "helm not found"; exit 1; }

echo "Prerequisites OK."

# ---- User Inputs ----
read -p "Enter Kubernetes namespace [nginx-ingress]: " NAMESPACE
NAMESPACE=${NAMESPACE:-nginx-ingress}

read -p "Enter Helm release name [nginx-plus]: " RELEASE
RELEASE=${RELEASE:-nginx-plus}

read -p "Enter full path to license.jwt: " JWT_PATH

if [ ! -f "$JWT_PATH" ]; then
  echo "JWT file not found."
  exit 1
fi

# ---- Namespace creation ----
kubectl get ns "$NAMESPACE" >/dev/null 2>&1 || kubectl create ns "$NAMESPACE"

# ---- Create Secrets ----
echo "Creating license secret..."
kubectl -n "$NAMESPACE" create secret generic nplus-license \
  --from-file=license.jwt="$JWT_PATH" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Creating registry secret..."
kubectl -n "$NAMESPACE" create secret docker-registry regcred \
  --docker-server=private-registry.nginx.com \
  --docker-username="$(cat "$JWT_PATH")" \
  --docker-password=none \
  --dry-run=client -o yaml | kubectl apply -f -

# ---- Helm Install ----
echo "Installing NGINX Plus Ingress Controller..."

helm install "$RELEASE" oci://ghcr.io/nginx/charts/nginx-ingress \
  --namespace "$NAMESPACE" \
  --version 2.4.3 \
  --set controller.image.repository=private-registry.nginx.com/nginx-ic/nginx-plus-ingress \
  --set controller.image.tag=5.3.3 \
  --set controller.nginxplus=true \
  --set controller.serviceAccount.imagePullSecretName=regcred \
  --set controller.mgmt.licenseTokenSecretName=nplus-license

echo "Installation complete."

# ---- Verification ----
echo "Checking pods..."
kubectl -n "$NAMESPACE" get pods

echo "Checking ingressclasses..."
kubectl get ingressclasses

echo "=============================================="
echo "NGINX Plus Ingress Controller Installed"
echo "=============================================="
