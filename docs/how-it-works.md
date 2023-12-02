# How it works ?
In this section we will break down the different steps that are involved in the installation and usage of Whanos.

## What ansible does  on the machines ?
### Install prerequisites

### Deploy the cluster

### Install docker registry
To deploy the docker registry, we will use official templates for the docker-registry and the ingress-nginx controller. We will also use official cert-manager helm chart to generate a self-signed certificate for the registry.

**Install Nginx ingress controller**
```shell
kubectl apply -f kube/init/nginx-ingress-controller/deployment.yaml
```

- **Wait for the ingress controller to be ready**
```shell
kubectl wait --namespace ingress-nginx \
--for=condition=ready pod \
--selector=app.kubernetes.io/component=controller \
--timeout=120s
```

- **Install cert-manager using Helm**
```shell
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
```

- **Wait for the cert-manager to be ready**
```shell
kubectl wait --namespace cert-manager \
--for=condition=ready pod \
--selector=app.kubernetes.io/component=webhook \
--timeout=120s
```

- **Create the ClusterIssuer for self-signed certificates**
```shell
kubectl apply -f kube/init/cert-manager/cluster-issuer.yaml
```

- **Deploy the docker registry**
```shell
kubectl apply -f kube/init/docker-registry/deployment.yaml
kubectl apply -f kube/init/docker-registry/ingress.yaml
```

- **Wait for the docker registry ingress to have an external IP and add it to /etc/hosts**
```shell
sudo sh -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for end point..."; external_ip=$(kubectl get ingress -n docker-registry docker-registry -o jsonpath="{.status.loadBalancer.ingress[0].ip}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip whanos-registry.local >> /etc/hosts'
```

- **Add the self-signed certificate to docker client truster certificates**
```shell
sudo mkdir -p /etc/docker/certs.d/whanos-registry.local:443/
kubectl get secret registry-tls -n docker-registry -o jsonpath='{.data.ca\.crt}' | base64 --decode > /etc/docker/certs.d/whanos-registry.local:443/ca.crt
```

### Install jenkins