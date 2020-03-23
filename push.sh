#!/bin/bash
echo "$DOCKER_PASSWORD" | docker login -u lustefaniak --password-stdin

if [[ -z "$VERSION" ]]; then
    FULL_VERSION=$(git describe --tags)
    VERSION=${FULL_VERSION//v}
fi

docker push "lustefaniak/docker-gcp-java:${NAME}_${VERSION}"
docker tag "lustefaniak/docker-gcp-java:${NAME}_${VERSION}" "lustefaniak/docker-gcp-java:${NAME}"
docker push "lustefaniak/docker-gcp-java:${NAME}"
