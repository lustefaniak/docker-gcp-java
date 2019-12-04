#!/usr/bin/env bash

# configure Stackdriver Profiler

export PROFILER_AGENT_COMMAND=${PROFILER_AGENT_COMMAND:-"-agentpath:/opt/cprof/profiler_java_agent.so=-cprof_service=${GCP_APP_NAME},-cprof_service_version=${GCP_APP_VERSION}"}
if is_true "$HEAP_PROFILER_ENABLE"; then
  PROFILER_AGENT_COMMAND=${PROFILER_AGENT_COMMAND},-cprof_enable_heap_sampling
fi

export PROFILER_AGENT=

if is_true "$PROFILER_ENABLE"; then
  PROFILER_AGENT=${PROFILER_AGENT_COMMAND}
fi
