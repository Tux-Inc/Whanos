#!/bin/bash

get_jenkins_port() {
  kubectl get svc -n whanos whanos-jenkins -o jsonpath='{.spec.ports[0].nodePort}'
}

get_whanos_registry_address() {
  kubectl get ingress -n docker-registry docker-registry -o jsonpath="{.status.loadBalancer.ingress[0].ip}"
}

printf "🚀 You can now access your Jenkins instance at http://localhost:%s\n" "$(get_jenkins_port)"
printf "🚀 You can now access your Docker registry at https://%s/\n" "$(get_whanos_registry_address)"
printf "🚀 You can now access your Kubernetes dashboard at http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/\n"