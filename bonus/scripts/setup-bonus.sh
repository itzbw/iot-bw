#!/bin/bash

set -e

echo "🚀 Setting up GitLab bonus..."

# Install Helm
if ! command -v helm &> /dev/null; then
    echo "Installing Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

# Add GitLab repo
helm repo add gitlab https://charts.gitlab.io/
helm repo update

# Create gitlab namespace
kubectl create namespace gitlab --dry-run=client -o yaml | kubectl apply -f -

# Install GitLab
echo "Installing GitLab (this takes 5-10 minutes)..."
helm install gitlab gitlab/gitlab \
  -n gitlab \
  -f ../confs/gitlab-values.yaml \
  --timeout 600s

# Wait for GitLab
echo "Waiting for GitLab..."
kubectl wait --for=condition=ready pod -l app=webservice -n gitlab --timeout=600s

echo "✅ GitLab installed!"
echo ""
echo "Access GitLab: kubectl port-forward svc/gitlab-webservice-default 8081:8080 -n gitlab"
echo "Username: root"
echo -n "Password: "
kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -ojsonpath='{.data.password}' | base64 --decode
echo ""