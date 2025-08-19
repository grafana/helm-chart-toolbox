#!/bin/bash

scriptDir=$(dirname "$(readlink -f "$0")")
source "${scriptDir}/common.sh"

usage() {
  echo "USAGE: promql.sh <query>"
  echo "Run a PromQL query against Prometheus or Mimir"
  echo
  echo "Required environment variables:"
  echo "  PROMETHEUS_URL - The query URL for your Prometheus service (e.g. localhost:9090/api/v1/query)"
  echo "  PROMETHEUS_TENANTID - The tenant ID for running PromQL queries"
  echo "  PROMETHEUS_USER - The username for running PromQL queries"
  echo "  PROMETHEUS_PASS - The password for running PromQL queries"
}

if [ -z "${1}" ] || [ "${1}" == "-h" ]; then
  usage
  exit 0
fi

metrics_query "${1}"
