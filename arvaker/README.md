# Install Odin
brew install odin

# Add deps
git clone git@github.com:laytan/odin-http.git lib

# Start server
odin run src/

# Run some basic tests
odin test test/

# Deployment stuff
## Build docker image
docker build -t arvaker:latest .

### For debugging, add "--progress=plain", and possibly "--no-cache"

## Apply docker image?
kubectl apply -f deployment.yaml

### Check status
minikube kubectl -- get pods

#### If failed, check logs with
minikube kubectl -- logs arvaker-deployment-XYZ

