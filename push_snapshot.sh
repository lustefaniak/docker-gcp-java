#!/bin/bash

if [[ -z "$VERSION" ]]; then
    FULL_VERSION=$(git describe --tags)
    VERSION=${FULL_VERSION//v}
fi

docker push "lustefaniak/docker-gcp-java:${NAME}_${VERSION}"