# docker-gcp-java

Docker image built from Alpine Linux, using GraalVM as JVM and with Stackdriver Debugger and Profiler binaries and scripts embedded.

Download from https://hub.docker.com/r/lustefaniak/docker-gcp-java

Base JVM image used is: [lustefaniak/docker-graalvm](https://github.com/lustefaniak/docker-graalvm) published to https://hub.docker.com/r/lustefaniak/docker-graalvm

This image is built from sourcecode of [GoogleCloudPlatform/openjdk-runtime](https://github.com/GoogleCloudPlatform/openjdk-runtime/). 
Main difference is use of GraalVM instead of OpenJdk. 
Because [GoogleCloudPlatform/openjdk-runtime](https://github.com/GoogleCloudPlatform/openjdk-runtime/) uses Debian as source of JVM, it has some problems around SSL implementation and ALPN setup due to wrong Debian OpenJDK packaging.
This image doesn't have such problems. 

## Usage

By default both debugger and profiler are disabled, to activate them set env variables in inheriting Dockerfile:

```
ENV PROFILER_ENABLE true
ENV DBG_ENABLE true
```

Or run with 

```
-e PROFILER_ENABLE=true -e DBG_ENABLE=true
```