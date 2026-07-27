#!/bin/bash

set -e

touch argocd-url argocd-password

echo "Creating ArgoCD namespace..."
kubectl get namespace argocd >/dev/null 2>&1 || \
kubectl create namespace argocd || true

echo "Installing ArgoCD..."
kubectl apply --server-side \
-n argocd \
-f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
sleep 10



echo "Waiting for ArgoCD pods to be ready..."
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s
sleep 3


echo "Exposing ArgoCD Server..."
kubectl patch svc argocd-server \
-n argocd \
-p '{"spec":{"type":"LoadBalancer"}}'
sleep 2


echo "Waiting for LoadBalancer IP..."
sleep 20

echo "Configuring ArgoCD in insecure mode..."

kubectl patch cm argocd-cmd-params-cm \
-n argocd \
--type merge \
-p '{"data":{"server.insecure":"true"}}'

echo "Restarting ArgoCD server..."

kubectl rollout restart deployment argocd-server -n argocd


sleep 10

echo "Getting ArgoCD URL..."

kubectl get svc argocd-server -n argocd >> argocd-url

echo "Fetching ArgoCD admin password..."
kubectl get secret argocd-initial-admin-secret \
-n argocd \
-o jsonpath="{.data.password}" | base64 -d >> argocd-password

echo "DONE"
