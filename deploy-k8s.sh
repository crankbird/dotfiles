#!/bin/bash
# Deploy to Kubernetes

echo "☸️ Deploying to Kubernetes..."

# Build and push images
skaffold build --push

# Deploy with Helm
helm upgrade --install my-ai-app ./infra/helm/my-ai-app \
  --namespace production \
  --create-namespace

echo "✅ Deployment complete!"
kubectl get pods -n production
