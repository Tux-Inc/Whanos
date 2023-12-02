#!/bin/bash
printf "Installing jenkins"
helm install whanos kube/helm/whanos --create-namespace --namespace whanos
printf "Installed jenkins ✅"
