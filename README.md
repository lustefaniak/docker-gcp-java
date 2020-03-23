# docker-gcp-java

Docker image built from Alpine Linux, using GraalVM as JVM and with Stackdriver Debugger and Profiler binaries and scripts embedded.

![Docker Image CI](https://github.com/lustefaniak/docker-gcp-java/workflows/Docker%20Image%20CI/badge.svg?branch=master&event=push)

Download from https://hub.docker.com/r/lustefaniak/docker-gcp-java

Base JVM image used is: [lustefaniak/docker-graalvm](https://github.com/lustefaniak/docker-graalvm) published to [Docker Hub](https://hub.docker.com/r/lustefaniak/docker-graalvm). There are also versions using `adoptopenjdk8` and `adoptopenjdk11`, check available [Docker Hub tags](https://hub.docker.com/r/lustefaniak/docker-gcp-java/tags).

This image is built from the sources of [GoogleCloudPlatform/openjdk-runtime](https://github.com/GoogleCloudPlatform/openjdk-runtime/) with additional changes.

Main difference is use of GraalVM instead of OpenJDK.
Because [GoogleCloudPlatform/openjdk-runtime](https://github.com/GoogleCloudPlatform/openjdk-runtime/) uses Debian as source of JVM, it has some problems around SSL implementation and ALPN setup due to wrong Debian OpenJDK packaging.
This image has no such problems.

## Usage

To make your application correctly recognized in UI set:

```docker
ENV GCP_APP_NAME "app-name"
ENV GCP_APP_VERSION "1.0.0"
```

Then run your application using provided launcher helper.

```docker
ENTRYPOINT ["/docker-entrypoint.bash"]
CMD ["java", "-version"]
```

You can also launch other script, just make sure it is executable

```docker
ENTRYPOINT ["/docker-entrypoint.bash"]
CMD ["/opt/app/bin/path_to_script.sh", "-version"]
```

### Memory allocation

By default launcher calculates available memory using cgroup limits. If for some reason detecting memory does not work you can set available bytes as `KUBERNETES_MEMORY_LIMIT` environment variable.

To better understand calculations of memory please check [setup-env.d/35-java-env.bash](setup-env.d/35-java-env.bash).

There are few flags which control calculation of memory. Probably two most important ones are `MIN_NON_HEAP_SIZE_MB` and `HEAP_SIZE_RATIO`.

By default `HEAP_SIZE_RATIO` is set to `80` meaning 80% of available memory.

By default `MIN_NON_HEAP_SIZE_MB` is set to `200`. It is used to workaround non-heap memory issues on small containers, eg. <512MB.

When calculated `NON_HEAP_SIZE_MB < MIN_NON_HEAP_SIZE_MB`, it changes to `MIN_NON_HEAP_SIZE_MB` and `HEAP_SIZE_RATIO` is adjusted.

If you know your application won't need non-heap memory(except classloader which will be ok with 200MB by default), you can set `HEAP_SIZE_RATIO` to `100` (100%), in such case it will automatically alocate for heap `HEAP_SIZE_MB = GAE_MEMORY_MB - MIN_NON_HEAP_SIZE_MB`

### Profiler and debugger

By default both debugger and profiler are disabled, to activate them set env variables in inheriting Dockerfile:

```
ENV PROFILER_ENABLE true
ENV DBG_ENABLE true
```

Or run with

```bash
-e PROFILER_ENABLE=true -e DBG_ENABLE=true
```

### Heap sampling
Heap sampling is available only for Java 11 and newer. To enable it add environment variables:

```bash
-e HEAP_PROFILER_ENABLE=true -e PROFILER_ENABLE=true
```

### Heap dump on OOM

By default it will exit JVM on OOM, to control that you can set `JAVA_EXIT_ON_OOM=false`.

If you want heap-dump generated on OOM set `JAVA_HEAP_DUMP_ON_OOM=true`, generated image will be stored to `JAVA_HEAP_DUMP_PATH` which by default is `/var/log/app_engine/heapdump/`.

There is also possibility to automatically upload generated heap dump to GCS, to do that configure:

```docker
ENV UPLOAD_HEAP_DUMP true
ENV GCS_HEAP_DUMP_PROJECT_ID "project_id"
ENV GCS_HEAP_DUMP_BUCKET "gcs_bucket_name"
ENV GCS_HEAP_DUMP_PATH ""
```

Uploader needs to be authenticated, for more info check [Google documentation](https://developers.google.com/accounts/docs/application-default-credentials)
