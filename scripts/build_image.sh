#!/bin/bash
LANGUAGE=$1
NAME=$2

image_name=$DOCKER_REGISTRY/whanos/whanos-$NAME-$LANGUAGE

if [[ -f Dockerfile ]]; then
	docker build . -t "$image_name"
else
	docker build . \
		-f /whanos/images/"${LANGUAGE}"/Dockerfile.standalone \
		-t "$image_name"
fi

if ! docker push "$image_name"; then
	exit 1
fi
