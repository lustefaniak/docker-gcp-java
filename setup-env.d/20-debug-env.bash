#!/usr/bin/env bash

# configure Cloud Debugger

export DBG_AGENT_COMMAND=${PROFILER_AGENT_COMMAND:-"-agentpath:/opt/cdbg/cdbg_java_agent.so="}

export DBG_AGENT=

if is_true "$DBG_ENABLE"; then
  DBG_AGENT="${DBG_AGENT_COMMAND} -Dcom.google.cdbg.module=${GCP_APP_NAME} -Dcom.google.cdbg.version=${GCP_APP_VERSION}"
fi
