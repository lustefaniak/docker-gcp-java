#!/bin/bash -x

if [[ -z "$NAME" ]]; then
    echo "Must provide NAME in environment" 1>&2
    exit 1
fi

if [[ -z "$VERSION" ]]; then
    FULL_VERSION=$(git describe --tags)
    VERSION=${FULL_VERSION//v}
fi

docker run --rm -e KUBERNETES_MEMORY_LIMIT=1048576000 "lustefaniak/docker-gcp-java:${NAME}_${VERSION}" || exit 1
docker run --rm -e KUBERNETES_MEMORY_LIMIT=1048576000 -e MIN_NON_HEAP_SIZE_MB=200 "lustefaniak/docker-gcp-java:${NAME}_${VERSION}" || exit 1
docker run --rm -e KUBERNETES_MEMORY_LIMIT=1048576000 -e HEAP_SIZE_RATIO=40 "lustefaniak/docker-gcp-java:${NAME}_${VERSION}" || exit 1
docker run --rm -e KUBERNETES_MEMORY_LIMIT=1048576000 -e HEAP_SIZE_RATIO=30 -e MIN_NON_HEAP_SIZE_MB=900 "lustefaniak/docker-gcp-java:${NAME}_${VERSION}" || exit 1