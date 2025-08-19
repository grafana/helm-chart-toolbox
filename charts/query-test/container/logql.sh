#!/bin/bash

scriptDir=$(dirname "$(readlink -f "$0")")
source "${scriptDir}/common.sh"

usage() {
  echo "USAGE: logql.sh <query>"
  echo "Run a LogQL query against Loki"
  echo
  echo "Required environment variables:"
  echo "  LOKI_URL - The query URL for your Loki service (e.g. localhost:9090/api/v1/query)"
  echo "  LOKI_TENANTID - The tenant ID for running LogQL queries"
  echo "  LOKI_USER - The username for running LogQL queries"
  echo "  LOKI_PASS - The password for running LogQL queries"
}

if [ -z "${1}" ] || [ "${1}" == "-h" ]; then
  usage
  exit 0
fi

logs_query "${1}"
