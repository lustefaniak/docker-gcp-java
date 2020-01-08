ARG BASE_IMAGE=lustefaniak/graalvm:11-19.3.0.2

FROM alpine:3.10.3 AS build

RUN apk add --no-cache procps alpine-baselayout wget unzip tar bash

ADD https://storage.googleapis.com/cloud-debugger/appengine-java/current/cdbg_java_agent.tar.gz /opt/cdbg/
RUN mkdir -p /opt/cprof/ && cd /opt/cprof/ && wget -q https://github.com/lustefaniak/cloud-profiler-java/suites/382711383/artifacts/929339 -O dist.zip && unzip -j dist.zip && rm dist.zip

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

FROM golang:1.13.5-alpine3.10 AS gcsupload
RUN mkdir /app
WORKDIR /app

RUN apk --no-cache add git 
COPY gcsupload/gcsupload.go /app
RUN go get -d -v .
RUN CGO_ENABLED=0 go build -installsuffix 'static' -o /gcsupload .

FROM ${BASE_IMAGE}

RUN apk add --no-cache alpine-baselayout ca-certificates bash curl procps

COPY --from=build /docker-entrypoint.bash /docker-entrypoint.bash
COPY --from=build /upload-heap-dump.bash /upload-heap-dump.bash
COPY --from=build /setup-env.d /setup-env.d/
COPY --from=build /shutdown/ /shutdown/

COPY --from=build /opt /opt
COPY --from=build /var/log/app_engine /var/log/app_engine
COPY --from=gcsupload /gcsupload /gcsupload

ENV GCP_APP_NAME "app-name"
ENV GCP_APP_VERSION "0.0.0"

ENV PROFILER_ENABLE false
ENV HEAP_PROFILER_ENABLE false
ENV DBG_ENABLE false

ENV JAVA_EXIT_ON_OOM true
ENV JAVA_HEAP_DUMP_ON_OOM false
ENV JAVA_HEAP_DUMP_PATH /var/log/app_engine/heapdump/
ENV UPLOAD_HEAP_DUMP false
ENV GCS_HEAP_DUMP_PROJECT_ID "project_id"
ENV GCS_HEAP_DUMP_BUCKET "gcs_bucket_name"
ENV GCS_HEAP_DUMP_COMPRESS "true"
ENV GCS_HEAP_DUMP_PATH ""

ENTRYPOINT ["/docker-entrypoint.bash"]
CMD ["java", "-version"]
