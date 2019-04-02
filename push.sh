#!/bin/bash
echo "$DOCKER_PASSWORD" | docker login -u lustefaniak --password-stdin

FULL_VERSION=$(git describe --tags)
VERSION=${FULL_VERSION//v}

docker push "lustefaniak/docker-gcp-java:${NAME}_${VERSION}"