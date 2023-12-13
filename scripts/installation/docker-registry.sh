#!/bin/bash
printf "Installing nginx ingress controller\n"
kubectl apply -f kube/init/nginx-ingress-controller/deployment.yaml
printf "Installed nginx ingress controller ✅\n\n\n"

printf "Waiting for ingress controller to be ready\n"
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s
printf "Ingress controller is ready ✅\n\n\n"

printf "Installing cert-manager\n"
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
printf "Installed cert-manager ✅\n\n\n"

printf "Waiting for cert-manager to be ready"
kubectl wait --namespace cert-manager \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=webhook \
  --timeout=120s
printf "Cert-manager is ready ✅\n\n\n"

printf "Deploying cluster issuer for cert-manager\n"
kubectl apply -f kube/init/cert-manager/cluster-issuer.yaml
printf "Deployed cluster issuer for cert-manager ✅\n\n\n"

printf "Deploying docker registry\n"
kubectl apply -f kube/init/docker-registry/deployment.yaml
kubectl apply -f kube/init/docker-registry/ingress.yaml
printf "Deployed docker registry ✅\n\n\n"

printf "Adding whanos-registry.local fake DNS to /etc/hosts\n"
sh -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for end point..."; external_ip=$(kubectl get ingress -n docker-registry docker-registry -o jsonpath="{.status.loadBalancer.ingress[0].ip}"); [ -z "$external_ip" ] && sleep 10; done; sudo echo "End point ready" && sudo sh -c "echo $external_ip whanos-registry.local >> /etc/hosts"'
printf "Added whanos-registry.local fake DNS to /etc/hosts ✅\n\n\n"

printf "Installing docker registry certificate\n"
sudo mkdir -p /etc/docker/certs.d/whanos-registry.local:443/
kubectl get secret registry-tls -n docker-registry -o jsonpath="{.data.ca\.crt}" | base64 --decode > /tmp/whanos-registry.local.crt && sudo mv /tmp/whanos-registry.local.crt /etc/docker/certs.d/whanos-registry.local:443/ca.crt
printf "Installed docker registry certificate ✅\n\n\n"