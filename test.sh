#!/bin/bash

if [[ -z "$NAME" ]]; then
    echo "Must provide NAME in environment" 1>&2
    exit 1
fi

if [[ -z "$VERSION" ]]; then
    FULL_VERSION=$(git describe --tags)
    VERSION=${FULL_VERSION//v}
fi

docker run --rm "lustefaniak/docker-gcp-java:${NAME}_${VERSION}" || exit 1