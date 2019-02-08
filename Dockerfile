FROM lustefaniak/docker-graalvm:alpine-1.0.0-rc12.0 AS build

RUN apk add --no-cache procps alpine-baselayout wget unzip tar

ADD https://storage.googleapis.com/cloud-debugger/appengine-java/current/cdbg_java_agent.tar.gz /opt/cdbg/
ADD https://storage.googleapis.com/cloud-profiler/java/latest/profiler_java_agent.tar.gz /opt/cprof/

COPY docker-entrypoint.bash /docker-entrypoint.bash
COPY setup-env.d /setup-env.d/
COPY shutdown/ /shutdown/

RUN tar Cxfvz /opt/cdbg /opt/cdbg/cdbg_java_agent.tar.gz --no-same-owner \
 && rm /opt/cdbg/cdbg_java_agent.tar.gz \
 && tar Cxfvz /opt/cprof /opt/cprof/profiler_java_agent.tar.gz --no-same-owner \
 && rm /opt/cprof/profiler_java_agent.tar.gz \
 && chmod +x /docker-entrypoint.bash /shutdown/*.bash /setup-env.d/*.bash \
 && mkdir /var/log/app_engine \
 && chmod go+rwx /var/log/app_engine

FROM lustefaniak/docker-graalvm:alpine-1.0.0-rc12.0

RUN apk add --no-cache procps alpine-baselayout bash

COPY --from=build /docker-entrypoint.bash /docker-entrypoint.bash
COPY --from=build /setup-env.d /setup-env.d/
COPY --from=build /shutdown/ /shutdown/

COPY --from=build /opt /opt
COPY --from=build /var/log/app_engine /var/log/app_engine

ENV GCP_APP_NAME "app-name"
ENV GCP_APP_VERSION "1.0.0"

ENV PROFILER_ENABLE false
ENV DBG_ENABLE false

ENTRYPOINT ["/docker-entrypoint.bash"]
CMD ["java", "-version"]
