# How it works ?
In this section we will break down the different steps that are involved in the installation and usage of Whanos.

## What ansible does  on the machines ?
### Install prerequisites

### Deploy the cluster

### Install basic tools
Before we start, we need to install some tools that will be used later on. We will install `kubectl`, `helm` on the control node.

- **Install kubectl**
```shell
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
printf 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
```

- **Configure kubectl**
```shell
mkdir -p ~/.kube
sudo cp /etc/kubernetes/admin.conf ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
```

- **Install helm**
```shell
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
```

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
sh -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for end point..."; external_ip=$(kubectl get ingress -n docker-registry docker-registry -o jsonpath="{.status.loadBalancer.ingress[0].ip}"); [ -z "$external_ip" ] && sleep 10; done; sudo echo "End point ready" && sudo sh -c "echo $external_ip whanos-registry.local >> /etc/hosts"'
```

- **Add the self-signed certificate to docker client truster certificates**
```shell
sudo mkdir -p /etc/docker/certs.d/whanos-registry.local:443/
kubectl get secret registry-tls -n docker-registry -o jsonpath="{.data.ca\.crt}" | base64 --decode > /tmp/whanos-registry.local.crt && sudo mv /tmp/whanos-registry.local.crt /etc/docker/certs.d/whanos-registry.local:443/ca.crt
```

### Install jenkins
To deploy jenkins, we will use official templates for the jenkins and the ingress-nginx controller. We will also use official cert-manager helm chart to generate a self-signed certificate for jenkins.
We customize the `values.yaml` file to match our needs.

- **Deploy jenkins release**
```shell
helm install whanos kube/helm/whanos --create-namespace --namespace whanos
```