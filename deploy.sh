#!/bin/bash

# Exit on error
set -e

# Default values
DEPLOY_FRONTEND=false
DEPLOY_BUNPASS=false
DEPLOY_ALL=false

# Display help information
function show_help {
  echo "Usage: ./deploy.sh [options]"
  echo "Options:"
  echo "  -h, --help       Display this help message"
  echo "  -a, --all        Deploy all services"
  echo "  -f, --frontend   Deploy frontend service"
  echo "  -b, --bunpass    Deploy bunpass service"
  echo "Example: ./deploy.sh --frontend --bunpass"
  echo "Example: ./deploy.sh --all"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
  -h | --help)
    show_help
    exit 0
    ;;
  -a | --all)
    DEPLOY_ALL=true
    shift
    ;;
  -f | --frontend)
    DEPLOY_FRONTEND=true
    shift
    ;;
  -b | --bunpass)
    DEPLOY_BUNPASS=true
    shift
    ;;
  *)
    echo "Unknown option: $1"
    show_help
    exit 1
    ;;
  esac
done

# If no options specified, prompt user
if [[ "$DEPLOY_ALL" == "false" && "$DEPLOY_FRONTEND" == "false" && "$DEPLOY_BUNPASS" == "false" ]]; then
  echo "No services specified. What would you like to deploy?"
  echo "1) All services"
  echo "2) Frontend only"
  echo "3) Bunpass only"
  echo "4) Exit"
  read -p "Enter choice [1-4]: " choice

  case $choice in
  1) DEPLOY_ALL=true ;;
  2) DEPLOY_FRONTEND=true ;;
  3) DEPLOY_BUNPASS=true ;;
  4) exit 0 ;;
  *)
    echo "Invalid choice. Exiting."
    exit 1
    ;;
  esac
fi

# If deploy all, set all flags to true
if [[ "$DEPLOY_ALL" == "true" ]]; then
  DEPLOY_FRONTEND=true
  DEPLOY_BUNPASS=true
fi

# Generate a unique tag
TAG=$(date +%s)
# Use the current user's minikube context
eval $(minikube docker-env)

function deploy_frontend {
  echo "===== Deploying Frontend ====="

  echo "Building frontend Docker image with tag $TAG..."
  docker build --no-cache -t daylightx-frontend:$TAG ./frontend/

  echo "Applying Kubernetes manifests..."
  kubectl apply -f ./frontend/kubernetes/frontend-config.yaml
  kubectl apply -f ./frontend/kubernetes/frontend.yaml

  echo "Setting deployment to use image daylightx-frontend:$TAG..."
  kubectl set image deployment/frontend-deployment frontend=daylightx-frontend:$TAG

  echo "Waiting for deployment to complete..."
  kubectl rollout status deployment frontend-deployment

  echo "Frontend deployed successfully!"
  minikube service frontend-service --url
}

# Function to deploy bunpass
function deploy_bunpass {
  echo "===== Deploying Bunpass ====="
  echo "Building bunpass Docker image..."
  docker build -t daylightx-bunpass:latest ./bunpass/

  echo "Loading image into Minikube..."
  minikube image load daylightx-bunpass:latest

  echo "Applying kubernetes manifests..."
  kubectl apply -f ./bunpass/kubernetes/bunpass.yaml

  echo "Restarting bunpass deployment..."
  kubectl rollout restart deployment bunpass

  echo "Waiting for deployment to complete..."
  kubectl rollout status deployment bunpass

  echo "Bunpass deployed successfully!"
}

# Deploy services according to flags
if [[ "$DEPLOY_FRONTEND" == "true" ]]; then
  deploy_frontend
fi

if [[ "$DEPLOY_BUNPASS" == "true" ]]; then
  deploy_bunpass
fi

# Show service URLs
echo ""
echo "===== Service URLs ====="
if [[ "$DEPLOY_FRONTEND" == "true" ]] || [[ "$DEPLOY_ALL" == "true" ]]; then
  echo "Frontend: Use command 'minikube service frontend-service' to access"
  FRONTEND_PORT=$(kubectl get service frontend-service -o jsonpath='{.spec.ports[0].nodePort}')
  if [[ ! -z "$FRONTEND_PORT" ]]; then
    echo "          Port: $FRONTEND_PORT (if accessing directly)"
  fi
fi

if [[ "$DEPLOY_BUNPASS" == "true" ]] || [[ "$DEPLOY_ALL" == "true" ]]; then
  echo "Bunpass (internal): http://bunpass-service:3000"
fi

echo ""
echo "All specified deployments completed successfully!"
