#!/bin/bash

# Exit on error
set -e

# Default values
DEPLOY_FRONTEND=false
DEPLOY_BUNPASS=false
DEPLOY_DELOREAN=false
DEPLOY_JANUS=false
DEPLOY_ARVAKER=false
DEPLOY_LUNAK=false
DEPLOY_REDIS=false
DEPLOY_ALL=false

# Display help information
function show_help {
  echo "Usage: ./deploy.sh [options]"
  echo "Options:"
  echo "  -h, --help       Display this help message"
  echo "  -A, --all        Deploy all services"
  echo "  -f, --frontend   Deploy frontend service"
  echo "  -b, --bunpass    Deploy bunpass service"
  echo "  -d, --delorean   Deploy delorean service"
  echo "  -j, --janus      Deploy Janus service"
  echo "  -a, --arvaker    Deploy Janus service"
  echo "  -l, --lunak      Deploy LunaK service"
  echo "  -r, --redis      Deploy Redis cache"
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
  -A | --all)
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
  -d | --delorean)
    DEPLOY_DELOREAN=true
    shift
    ;;
  -j | --janus)
    DEPLOY_JANUS=true
    shift
    ;;
  -a | --arvaker)
    DEPLOY_ARVAKER=true
    shift
    ;;
  -l | --lunak)
    DEPLOY_LUNAK=true
    shift
    ;;
  -r | --redis)
    DEPLOY_REDIS=true
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
if [[ 
  "$DEPLOY_ALL" == "false" &&
  "$DEPLOY_FRONTEND" == "false" &&
  "$DEPLOY_BUNPASS" == "false" &&
  "$DEPLOY_DELOREAN" == "false" &&
  "$DEPLOY_JANUS" == "false" &&
  "$DEPLOY_LUNAK" == "false" &&
  "$DEPLOY_ARVAKER" == "false" &&
  "$DEPLOY_REDIS" == "false" ]] \
  ; then
  echo "No services specified. What would you like to deploy?"
  echo "1) All services"
  echo "2) Frontend only"
  echo "3) Bunpass only"
  echo "4) Delorean only"
  echo "5) Janus only"
  echo "6) Arvaker only"
  echo "7) LunaK only"
  echo "8) Redis cache only"
  echo "9) Exit"
  read -p "Enter choice [1-9]: " choice

  case $choice in
  1) DEPLOY_ALL=true ;;
  2) DEPLOY_FRONTEND=true ;;
  3) DEPLOY_BUNPASS=true ;;
  4) DEPLOY_DELOREAN=true ;;
  5) DEPLOY_JANUS=true ;;
  6) DEPLOY_ARVAKER=true ;;
  7) DEPLOY_LUNAK=true ;;
  8) DEPLOY_REDIS=true ;;
  9) exit 0 ;;
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
  DEPLOY_DELOREAN=true
  DEPLOY_JANUS=true
  DEPLOY_ARVAKER=true
  DEPLOY_LUNAK=true
  DEPLOY_REDIS=true
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

  echo "Building bunpass Docker image... $TAG"
  docker build -t daylightx-bunpass:$TAG ./bunpass/

  echo "Applying kubernetes manifests..."
  kubectl apply -f ./bunpass/kubernetes/bunpass.yaml

  echo "Setting deployment to use image daylightx-bunpass:$TAG..."
  kubectl set image deployment/bunpass-deployment bunpass=daylightx-bunpass:$TAG

  echo "Restarting bunpass deployment..."
  # Change this line to use bunpass-deployment instead of bunpass
  kubectl rollout restart deployment bunpass-deployment

  echo "Waiting for deployment to complete..."
  # Change this line as well
  kubectl rollout status deployment bunpass-deployment

  echo "Bunpass deployed successfully!"
}

# Function to deploy delorean
function deploy_delorean {
  echo "===== Deploying delorean ====="
  echo "Building delorean Docker image with $TAG..."
  docker build -t delorean:$TAG ./delorean/

  echo "Applying kubernetes manifests..."
  kubectl apply -f ./delorean/deployment.yaml
  kubectl apply -f ./delorean/service.yaml

  echo "Setting deployment to use image delorean:$TAG..."
  kubectl set image deployment/delorean delorean=delorean:$TAG

  echo "Restarting delorean deployment..."
  kubectl rollout restart deployment delorean

  echo "Waiting for deployment to complete..."
  kubectl rollout status deployment delorean

  echo "Delorean deployed successfully!"
}

# Function to deploy arvaker
function deploy_arvaker {
  echo "===== Deploying arvaker ====="
  echo "Building arvaker Docker image with $TAG..."
  docker build -t arvaker:$TAG ./arvaker/

  echo "Applying kubernetes manifests..."
  kubectl apply -f ./arvaker/deployment.yaml
  kubectl apply -f ./arvaker/service.yaml

  echo "Setting deployment to use image arvaker:$TAG..."
  kubectl set image deployment/arvaker arvaker=arvaker:$TAG

  echo "Restarting arvaker deployment..."
  kubectl rollout restart deployment arvaker

  echo "Waiting for deployment to complete..."
  kubectl rollout status deployment arvaker

  echo "Arvaker deployed successfully!"
}

# Function to deploy LunaK
function deploy_lunak {
  echo "===== Deploying LunaK ====="

  echo "Building LunaK Docker image... $TAG"
  docker build -t daylightx-lunak:$TAG ./LunaK/

  echo "Applying kubernetes manifests..."
  kubectl apply -f ./LunaK/kubernetes/LunaK.yaml

  echo "Setting deployment to use image daylightx-lunak:$TAG..."
  kubectl set image deployment/lunak-deployment lunak=daylightx-lunak:$TAG

  echo "Restarting LunaK deployment..."
  # Change this line to use lunak-deployment instead of LunaK
  kubectl rollout restart deployment lunak-deployment

  echo "Waiting for deployment to complete..."
  # Change this line as well
  kubectl rollout status deployment lunak-deployment

  echo "LunaK deployed successfully!"
}

# Function to deploy janus
function deploy_janus {
  echo "===== Deploying Janus ====="

  # Check if the secret exists, if not create it
  if ! kubectl get secret janus-secrets &>/dev/null; then
    echo "Creating janus-secrets..."
    # Generate a random key using openssl (available in most environments)
    SECRET_KEY=$(openssl rand -base64 48)
    kubectl create secret generic janus-secrets --from-literal=SECRET_KEY_BASE=$SECRET_KEY
  fi

  echo "Building janus Docker image... $TAG"
  docker build -t daylightx-janus:$TAG ./janus/

  echo "Applying kubernetes manifests..."
  kubectl apply -f ./janus/kubernetes/janus.yaml

  echo "Setting deployment to use image daylightx-janus:$TAG..."
  kubectl set image deployment/janus-deployment janus=daylightx-janus:$TAG

  echo "Restarting janus deployment..."
  # Change this line to use janus-deployment instead of janus
  kubectl rollout restart deployment janus-deployment

  echo "Waiting for deployment to complete..."
  # Change this line as well
  kubectl rollout status deployment janus-deployment

  echo "Janus deployed successfully!"
}

# Function to deploy Redis
function deploy_redis {
  echo "===== Deploying Redis Cache ====="

  # Check if Helm is installed
  if ! command -v helm &>/dev/null; then
    echo "Helm could not be found. You need to install Helm first."
    echo "Run the following commands to install Helm:"
    echo ""
    echo "# Add the Helm repository GPG key"
    echo "curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null"
    echo ""
    echo "# Add the Helm repository"
    echo "echo \"deb [arch=\$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main\" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list"
    echo ""
    echo "# Update package list"
    echo "sudo apt update"
    echo ""
    echo "# Install Helm"
    echo "sudo apt install helm"
    echo ""
    echo "After installing Helm, run this script again with the --redis flag."
    return 1
  fi

  # Add Bitnami repo if it doesn't exist
  if ! helm repo list | grep -q "bitnami"; then
    echo "Adding Bitnami Helm repository..."
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm repo update
  fi

  # Generate a random password for Redis
  REDIS_PASSWORD=$(openssl rand -base64 16)

  # Create a values file for Redis configuration
  REDIS_VALUES_FILE="redis-values.yaml"
  echo "# Redis values for deployment" >$REDIS_VALUES_FILE
  echo "auth:" >>$REDIS_VALUES_FILE
  echo "  password: \"$REDIS_PASSWORD\"" >>$REDIS_VALUES_FILE
  echo "master:" >>$REDIS_VALUES_FILE
  echo "  persistence:" >>$REDIS_VALUES_FILE
  echo "    enabled: true" >>$REDIS_VALUES_FILE
  echo "  resources:" >>$REDIS_VALUES_FILE
  echo "    requests:" >>$REDIS_VALUES_FILE
  echo "      memory: 128Mi" >>$REDIS_VALUES_FILE
  echo "      cpu: 100m" >>$REDIS_VALUES_FILE
  echo "replica:" >>$REDIS_VALUES_FILE
  echo "  replicaCount: 1" >>$REDIS_VALUES_FILE
  echo "  persistence:" >>$REDIS_VALUES_FILE
  echo "    enabled: true" >>$REDIS_VALUES_FILE
  echo "  resources:" >>$REDIS_VALUES_FILE
  echo "    requests:" >>$REDIS_VALUES_FILE
  echo "      memory: 128Mi" >>$REDIS_VALUES_FILE
  echo "      cpu: 100m" >>$REDIS_VALUES_FILE

  # Check if Redis is already deployed
  if helm list | grep -q "redis"; then
    echo "Redis is already deployed. Upgrading with new configuration..."
    helm upgrade redis bitnami/redis -f $REDIS_VALUES_FILE
  else
    echo "Installing Redis using Helm..."
    helm install redis bitnami/redis -f $REDIS_VALUES_FILE
  fi

  # Wait for Redis to be ready
  echo "Waiting for Redis deployment to complete..."
  kubectl rollout status statefulset/redis-master
  kubectl rollout status statefulset/redis-replicas

  # Store the password in a Kubernetes secret for applications to use
  echo "Creating Kubernetes secret with Redis credentials..."
  kubectl create secret generic redis-credentials \
    --from-literal=redis-password=$REDIS_PASSWORD \
    --from-literal=redis-host=redis-master \
    --from-literal=redis-port=6379 \
    --dry-run=client -o yaml | kubectl apply -f -

  echo "Redis deployed successfully!"
  echo ""
  echo "Redis connection information:"
  echo "  Host: redis-master"
  echo "  Port: 6379"
  echo "  Password has been stored in Kubernetes secret 'redis-credentials'"
  echo ""
  echo "To retrieve the Redis password:"
  echo "  kubectl get secret redis-credentials -o jsonpath='{.data.redis-password}' | base64 --decode"
  echo ""
  echo "To connect to Redis from within the cluster:"
  echo "  kubectl exec -it redis-master-0 -- redis-cli -a \$(kubectl get secret redis-credentials -o jsonpath='{.data.redis-password}' | base64 --decode)"
  echo ""
  echo "To update your microservices to use Redis cache:"
  echo "  1. Add environment variables from the 'redis-credentials' secret"
  echo "  2. Update your code to use the Redis client with the provided credentials"
  echo "  3. Redeploy your microservices to apply the changes"

  # Create a ConfigMap with example code for using Redis in different languages
  echo "Creating ConfigMap with Redis usage examples..."
  cat <<EOL >redis-examples-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: redis-examples
data:
  nodejs-example.js: |
    // Example Redis usage in Node.js
    const Redis = require('ioredis');

    // Connection using environment variables
    const redis = new Redis({
      host: process.env.REDIS_HOST || 'redis-master',
      port: process.env.REDIS_PORT || 6379,
      password: process.env.REDIS_PASSWORD
    });

    // Example cache implementation
    async function getDataWithCache(key) {
      // Try to get from cache
      const cachedData = await redis.get(key);
      if (cachedData) {
        console.log('Cache hit');
        return JSON.parse(cachedData);
      }

      console.log('Cache miss');
      // Fetch from API or database
      const data = await fetchFromApi();

      // Store in cache with TTL (1 hour)
      await redis.set(key, JSON.stringify(data), 'EX', 3600);

      return data;
    }

  python-example.py: |
    # Example Redis usage in Python
    import redis
    import json
    import os

    # Connection using environment variables
    r = redis.Redis(
        host=os.environ.get('REDIS_HOST', 'redis-master'),
        port=os.environ.get('REDIS_PORT', 6379),
        password=os.environ.get('REDIS_PASSWORD', '')
    )

    # Example cache implementation
    def get_data_with_cache(key):
        # Try to get from cache
        cached_data = r.get(key)
        if cached_data:
            print('Cache hit')
            return json.loads(cached_data)

        print('Cache miss')
        # Fetch from API or database
        data = fetch_from_api()

        # Store in cache with TTL (1 hour)
        r.setex(key, 3600, json.dumps(data))

        return data
EOL

  kubectl apply -f redis-examples-configmap.yaml
  echo "Created ConfigMap 'redis-examples' with sample code."
  echo "View examples with: kubectl get configmap redis-examples -o yaml"
}

# Deploy services according to flags
if [[ "$DEPLOY_REDIS" == "true" ]]; then
  deploy_redis
fi

if [[ "$DEPLOY_BUNPASS" == "true" ]]; then
  deploy_bunpass
fi

if [[ "$DEPLOY_DELOREAN" == "true" ]]; then
  deploy_delorean
fi

if [[ "$DEPLOY_JANUS" == "true" ]]; then
  deploy_janus
fi

if [[ "$DEPLOY_ARVAKER" == "true" ]]; then
  deploy_arvaker
fi

if [[ "$DEPLOY_LUNAK" == "true" ]]; then
  deploy_lunak
fi

# Ensure frontend is deployed last
if [[ "$DEPLOY_FRONTEND" == "true" ]]; then
  deploy_frontend
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

if [[ "$DEPLOY_LUNAK" == "true" ]] || [[ "$DEPLOY_ALL" == "true" ]]; then
  echo "LunaK (internal): http://lunak-service:8080"
fi

if [[ "$DEPLOY_DELOREAN" == "true" ]] || [[ "$DEPLOY_ALL" == "true" ]]; then
  echo "Delorean (internal): http://delorean:8000"
fi

if [[ "$DEPLOY_JANUS" == "true" ]] || [[ "$DEPLOY_ALL" == "true" ]]; then
  echo "Janus (internal): http://janus-service:4000"
fi

if [[ "$DEPLOY_ARVAKER" == "true" ]] || [[ "$DEPLOY_ALL" == "true" ]]; then
  echo "Arvaker (internal): http://arvaker-service:8000"
fi

if [[ "$DEPLOY_REDIS" == "true" ]] || [[ "$DEPLOY_ALL" == "true" ]]; then
  echo "Redis Cache (internal): redis-master:6379"
  echo "Redis Secret: kubectl get secret redis-credentials -o jsonpath='{.data.redis-password}' | base64 --decode"
fi

echo ""
echo "All specified deployments completed successfully!"
