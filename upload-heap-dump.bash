#!/usr/bin/env bash

is_true() {
  # case insensitive check for "true"
  if [[ ${1,,} = "true" ]]; then
    true
  else
    false
  fi
}

GCS_HEAP_DUMP_UPLOADER=${GCS_HEAP_DUMP_UPLOADER:-/gcsupload}

FILE_SUFFIX=""
if is_true "true"; then
  FILE_SUFFIX=".gz"
fi


for heapdump in ${JAVA_HEAP_DUMP_PATH}/*.hprof; do
    TARGET_NAME="${GCS_HEAP_DUMP_PATH}${GCP_APP_NAME}-${GCP_APP_VERSION}-$(date +%Y-%m-%dT%H:%M:%S%z)-$(hostname).hprof${FILE_SUFFIX}"
    echo "Uploading ${heapdump} to project ${GCS_HEAP_DUMP_PROJECT_ID} bucket ${GCS_HEAP_DUMP_BUCKET} as ${TARGET_NAME}"
    echo ${GCS_HEAP_DUMP_UPLOADER} --source "${heapdump}" --name ${TARGET_NAME} --gzip ${GCS_HEAP_DUMP_COMPRESS}
    ${GCS_HEAP_DUMP_UPLOADER} --source "${heapdump}" --name ${TARGET_NAME} --gzip ${GCS_HEAP_DUMP_COMPRESS} && rm "${heapdump}"
done
