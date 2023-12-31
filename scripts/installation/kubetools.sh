#!/bin/bash
#printf "🏗️ Installing kubectl\n"
#sudo apt-get update
#sudo apt-get install -y apt-transport-https ca-certificates curl
#curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
#printf 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
#sudo apt-get update
#sudo apt-get install -y kubectl
#printf "✅ Installed kubectl\n\n\n"

#printf "🏗️ Configuring kubectl\n"
#mkdir -p ~/.kube
#sudo cp /etc/kubernetes/admin.conf ~/.kube/config
#sudo chown $(id -u):$(id -g) ~/.kube/config
#printf "✅ Configured kubectl\n\n\n"

printf "🏗️ Installing helm\n"
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
printf "✅ Installed helm\n\n\n"