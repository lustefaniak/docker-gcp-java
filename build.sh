#!/usr/bin/env bash

if [[ -z "$NAME" ]]; then
    echo "Must provide NAME in environment" 1>&2
    exit 1
fi

if [[ -z "$BASE_IMAGE" ]]; then
    echo "Must provide BASE in environment" 1>&2
    exit 1
fi

FULL_VERSION=$(git describe --tags)
VERSION=${FULL_VERSION//v}

echo "Building using NAME=$NAME BASE_IMAGE=$BASE_IMAGE VERSION=$VERSION"

docker build . --build-arg BASE_IMAGE="${BASE_IMAGE}" -t "lustefaniak/docker-gcp-java:${NAME}_${VERSION}"
