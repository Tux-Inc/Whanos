#!/bin/bash
printf "Installing nginx ingress controller"
kubectl apply -f kube/init/nginx-ingress-controller/deployment.yaml
printf "Installed nginx ingress controller ✅"

printf "Waiting for ingress controller to be ready"
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s
printf "Ingress controller is ready ✅"

printf "Installing cert-manager"
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.5.4 \
  --set installCRDs=true \
  --set ingressShim.defaultIssuerName=letsencrypt-prod \
  --set ingressShim.defaultIssuerKind=ClusterIssuer \
  --set ingressShim.defaultIssuerGroup=cert-manager.io
printf "Installed cert-manager ✅"

printf "Waiting for cert-manager to be ready"
kubectl wait --namespace cert-manager \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=webhook \
  --timeout=120s
printf "Cert-manager is ready ✅"

printf "Deploying cluster issuer for cert-manager"
kubectl apply -f kube/init/cert-manager/cluster-issuer.yaml
printf "Deployed cluster issuer for cert-manager ✅"

printf "Deploying docker registry"
kubectl apply -f kube/init/docker-registry/deployment.yaml
kubectl apply -f kube/init/docker-registry/ingress.yaml
printf "Deployed docker registry ✅"

printf "Adding whanos-registry.local fake DNS to /etc/hosts"
sudo sh -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for end point..."; external_ip=$(kubectl get ingress -n docker-registry docker-registry -o jsonpath="{.status.loadBalancer.ingress[0].ip}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip whanos-registry.local >> /etc/hosts'
printf "Added whanos-registry.local fake DNS to /etc/hosts ✅"

printf "Installing docker registry certificate"
sudo mkdir -p /etc/docker/certs.d/whanos-registry.local:443/
kubectl get secret registry-tls -n docker-registry -o jsonpath='{.data.ca\.crt}' | base64 --decode > /etc/docker/certs.d/whanos-registry.local:443/ca.crt
printf "Installed docker registry certificate ✅"