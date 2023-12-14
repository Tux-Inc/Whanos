#!/bin/bash
LANGUAGE=$1
NAME=$2

image_name=$DOCKER_REGISTRY/whanos/whanos-$NAME-$LANGUAGE

if [[ -f whanos.yml ]]; then
	helm upgrade -if whanos.yml "$NAME" /whanos/helm/whanos-deploy --set image.image="$image_name" --set image.name="$NAME-name"

	external_ip=""
	ip_timeout=20
	echo "Trying to get the external IP:"
	while [ -z $external_ip ]; do
		if [[ "$ip_timeout" -eq "0" ]]; then
			ip_timeout="Couldn't get the IP: Timeout"
			break
		fi
		sleep 5
		echo -n "."
		external_ip=$(kubectl get svc "$NAME"-lb --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")
		ip_timeout=$(($ip_timeout - 1))
	done

	echo "."
	echo "$external_ip"
else
  exit 0
	if helm status "$NAME" &> /dev/null; then
		helm uninstall "$NAME"
	fi
fi
