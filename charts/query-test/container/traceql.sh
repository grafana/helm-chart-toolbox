#!/bin/bash

scriptDir=$(dirname "$(readlink -f "$0")")
source "${scriptDir}/common.sh"

usage() {
  echo "USAGE: traceql.sh <query>"
  echo "Run a TraceQL query against Tempo"
  echo
  echo "Required environment variables:"
  echo "  TEMPO_URL - The search URL for your Tempo service (e.g. localhost:9090/api/search)"
  echo "  TEMPO_USER - The username for running TraceQL queries"
  echo "  TEMPO_PASS - The password for running TraceQL queries"
}

if [ -z "${1}" ] || [ "${1}" == "-h" ]; then
  usage
  exit 0
fi

traces_query "${1}"
