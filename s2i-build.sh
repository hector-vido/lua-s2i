#!/bin/bash

CONTAINER_ENGINE=podman
if [ -n "$(which docker)" ]; then
	CONTAINER_ENGINE=docker
fi

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
	echo 'Usage: s2i-build <source> <image> <tag>'
	exit 1
fi

s2i build --as-dockerfile s2i.Dockerfile $1 $2 $3

$CONTAINER_ENGINE build -t $3 -f s2i.Dockerfile .

rm -rf s2i.Dockerfile downloads/ upload/
