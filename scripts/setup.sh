#!/bin/bash

CLUSTER_NAME="recsys-cluster-dev"

# Check for Docker, Kind, Kubectl, Helm, and Tilt
echo "Checking for required packages."
check_command() {
    if command -v "$1" &> /dev/null; then
        echo "$1 is installed."
    else
        echo "$1 is not installed. Please install $1 to proceed."
        exit 1
    fi
}
check_command "docker"
check_command "kind"
check_command "kubectl"
check_command "helm"
check_command "tilt"

# Create Kind cluster if it doesn't exit
echo "Creating Kind cluster."
kind create cluster --name "$CLUSTER_NAME" --config dev/kind-config.yaml --wait 3m || {
    echo "Failed to create Kind cluster."
    exit 1
}

# Install NGINX Ingress Controller
echo "Installing NGINX Ingress Controller."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Wait for Ingress to be ready
echo "Waiting for Ingress controller to be ready."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s


# Create Namespaces for all services
echo "Creating service namespaces."
create_namespace() {
    kubectl create namespace $1
}
create_namespace "orchestrator-app"
create_namespace "feature-store-app"
create_namespace "candidate-gen-app"
create_namespace "filtering-app"
create_namespace "ranking-app"





