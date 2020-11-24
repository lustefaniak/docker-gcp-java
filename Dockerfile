ARG BASE_IMAGE=lustefaniak/graalvm:11-20.3.0

FROM alpine:3.12.1 AS build

RUN apk add --no-cache procps alpine-baselayout wget unzip tar bash

ADD https://storage.googleapis.com/cloud-debugger/appengine-java/current/cdbg_java_agent.tar.gz /opt/cdbg/
ADD https://storage.googleapis.com/cloud-profiler/java/latest/profiler_java_agent.tar.gz /opt/cprof/

COPY docker-entrypoint.bash /docker-entrypoint.bash
COPY upload-heap-dump.bash /upload-heap-dump.bash
COPY setup-env.d /setup-env.d/
COPY shutdown/ /shutdown/

RUN tar Cxfvz /opt/cdbg /opt/cdbg/cdbg_java_agent.tar.gz --no-same-owner \
    && rm /opt/cdbg/cdbg_java_agent.tar.gz \
    && tar Cxfvz /opt/cprof /opt/cprof/profiler_java_agent.tar.gz --no-same-owner \
    && rm /opt/cprof/profiler_java_agent.tar.gz \
    && chmod +x /docker-entrypoint.bash /upload-heap-dump.bash /shutdown/*.bash /setup-env.d/*.bash \
    && mkdir -p /var/log/app_engine/heapdump \
    && chmod go+rwx -R /var/log/app_engine

FROM lustefaniak/gcsupload:latest AS gcsupload
FROM ${BASE_IMAGE}

COPY --from=build /docker-entrypoint.bash /docker-entrypoint.bash
COPY --from=build /upload-heap-dump.bash /upload-heap-dump.bash
COPY --from=build /setup-env.d /setup-env.d/
COPY --from=build /shutdown/ /shutdown/

COPY --from=build /opt /opt
COPY --from=build /var/log/app_engine /var/log/app_engine
COPY --from=gcsupload /gcsupload /gcsupload

RUN apt-get update \
    && apt-get install -y --no-install-recommends libjemalloc2 libjemalloc-dev bc \
    && rm -rf /var/lib/apt/lists/*

ARG PLATFORM_DEPS="echo No extra setup"
RUN sh -c "${PLATFORM_DEPS}"

ENV GCP_APP_NAME="app-name" \
    GCP_APP_VERSION="0.0.0" \
    PROFILER_ENABLE=false \
    HEAP_PROFILER_ENABLE=false \
    DBG_ENABLE=false \
    JAVA_EXIT_ON_OOM=true \
    JAVA_HEAP_DUMP_ON_OOM=false \
    JAVA_HEAP_DUMP_PATH=/var/log/app_engine/heapdump/ \
    UPLOAD_HEAP_DUMP=false \
    GCS_HEAP_DUMP_PROJECT_ID="project_id" \
    GCS_HEAP_DUMP_BUCKET="gcs_bucket_name" \
    GCS_HEAP_DUMP_COMPRESS="true" \
    GCS_HEAP_DUMP_PATH="" 

ENTRYPOINT ["/docker-entrypoint.bash"]
CMD ["java", "-version"]
