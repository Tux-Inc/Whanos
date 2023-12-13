#!/bin/bash
printf "Installing jenkins\n"
helm install whanos kube/helm/whanos --create-namespace --namespace whanos
printf "Installed jenkins ✅\n\n\n"
