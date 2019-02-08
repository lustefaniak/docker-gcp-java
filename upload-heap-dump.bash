#!/bin/bash

for heapdump in ${JAVA_HEAP_DUMP_PATH}/*.hprof; do
    TARGET_NAME=${GCS_HEAP_DUMP_PATH}${GCP_APP_NAME}-${GCP_APP_VERSION}-$(date +%Y-%m-%dT%H:%M:%S%z)-$(hostname).hprof
    echo "Uploading ${heapdump} to project ${GCS_HEAP_DUMP_PROJECT_ID} bucket ${GCS_HEAP_DUMP_BUCKET} as ${TARGET_NAME}"
    /gcsupload --project ${GCS_HEAP_DUMP_PROJECT_ID} --source ${heapdump} --bucket ${GCS_HEAP_DUMP_BUCKET} --name ${TARGET_NAME} --public false
done
