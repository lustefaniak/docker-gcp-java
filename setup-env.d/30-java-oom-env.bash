#!/bin/bash

# configure Heap dump on OOM

export UPLOAD_HEAP_COMMAND=${UPLOAD_HEAP_COMMAND:-/upload-heap-dump.bash}

JAVA_HEAP_DUMP_ON_OOM_OPT=""
JAVA_EXIT_ON_OOM_OPT=""
UPLOAD_HEAP_DUMP_OPT=""

if is_true "$JAVA_HEAP_DUMP_ON_OOM"; then
  JAVA_HEAP_DUMP_ON_OOM_OPT="-XX:HeapDumpPath=${JAVA_HEAP_DUMP_PATH} -XX:+HeapDumpOnOutOfMemoryError"

  if is_true "$UPLOAD_HEAP_DUMP"; then
    UPLOAD_HEAP_DUMP_OPT="-XX:OnOutOfMemoryError=${UPLOAD_HEAP_COMMAND}"
  fi
fi

if is_true "$JAVA_EXIT_ON_OOM"; then
  JAVA_EXIT_ON_OOM_OPT="-XX:+ExitOnOutOfMemoryError"
fi

export JAVA_OOM_OPTS=${JAVA_OOM_OPTS:-"${JAVA_HEAP_DUMP_ON_OOM_OPT} ${JAVA_EXIT_ON_OOM_OPT} ${UPLOAD_HEAP_DUMP_OPT}"}