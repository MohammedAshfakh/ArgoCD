#!/bin/bash

set -e

echo "Creating monitoring namespace..."
kubectl create namespace monitoring || true

echo "Adding Helm repo..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo update

echo "Installing Prometheus + Grafana stack..."
helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring

echo "Waiting for pods to be ready..."
kubectl wait --for=condition=Ready pods --all -n monitoring --timeout=600s

echo "Checking services..."
kubectl get svc -n monitoring > monitoring-svc.details

echo "Monitoring setup completed"
