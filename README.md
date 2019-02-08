# docker-gcp-java

Docker image built from Alpine Linux, using GraalVM as JVM and with Stackdriver Debugger and Profiler binaries and scripts embedded.

Download from https://hub.docker.com/r/lustefaniak/docker-gcp-java

Base JVM image used is: [lustefaniak/docker-graalvm](https://github.com/lustefaniak/docker-graalvm) published to https://hub.docker.com/r/lustefaniak/docker-graalvm

This image is built from sourcecode of [GoogleCloudPlatform/openjdk-runtime](https://github.com/GoogleCloudPlatform/openjdk-runtime/) with additional changes. 

Main difference is use of GraalVM instead of OpenJDK. 
Because [GoogleCloudPlatform/openjdk-runtime](https://github.com/GoogleCloudPlatform/openjdk-runtime/) uses Debian as source of JVM, it has some problems around SSL implementation and ALPN setup due to wrong Debian OpenJDK packaging.
This image has no such problems. 

## Usage

To make your application correctly recognized in UI set:

```
ENV GCP_APP_NAME "app-name"
ENV GCP_APP_VERSION "1.0.0"
```

### Profiler and debugger

By default both debugger and profiler are disabled, to activate them set env variables in inheriting Dockerfile:

```
ENV PROFILER_ENABLE true
ENV DBG_ENABLE true
```

Or run with 

```
-e PROFILER_ENABLE=true -e DBG_ENABLE=true
```


### Heap dump on OOM

By default it will exit JVM on OOM, to control that you can set `JAVA_EXIT_ON_OOM=false`.

If you want heap-dump generated on OOM set `JAVA_HEAP_DUMP_ON_OOM=true`, generated image will be stored to `JAVA_HEAP_DUMP_PATH` which by default is `/var/log/app_engine/heapdump/`.

There is also possibility to automatically upload generated heap dump to GCS, to do that configure:

```
ENV UPLOAD_HEAP_DUMP true
ENV GCS_HEAP_DUMP_PROJECT_ID "project_id"
ENV GCS_HEAP_DUMP_BUCKET "gcs_bucket_name"
ENV GCS_HEAP_DUMP_PATH ""
```

Uploader needs to be authenticated, for more info check https://developers.google.com/accounts/docs/application-default-credentials