if [[ -f whanos.yml ]]; then
	helm upgrade -if whanos.yml "$1" /whanos/helm/AutoDeploy --set image.image=$image_name --set image.name="$1-name"

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
		external_ip=$(kubectl get svc $1-lb --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")
		ip_timeout=$(($ip_timeout - 1))
	done

	echo "."
	echo "$external_ip"
else
	if helm status "$1" &> /dev/null; then
		helm uninstall "$1"
	fi
fi
