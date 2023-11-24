#!/bin/bash
LANGUAGE=$1

if [[ -f Dockerfile ]]; then
	docker build . -t $image_name
else
	docker build . \
		-f /images/${LANGUAGE}/Dockerfile.standalone \
		-t $image_name
fi

if ! docker push $image_name; then
	exit 1
fi
