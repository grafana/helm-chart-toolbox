#!/bin/bash

scriptDir=$(dirname "$(readlink -f "$0")")
source "${scriptDir}/common.sh"

usage() {
  echo "USAGE: generate.sh [config.json]"
  echo "Run a PromQL query and print a YAML snapshot of the metric names and the"
  echo "number of series returned for each one. Save this output as the baseline file."
  echo
  echo "Arguments:"
  echo "  config.json - The test configuration (default: /etc/config/config.json)"
  echo
  echo "Required environment variables:"
  echo "  PROMETHEUS_URL - The query URL for your Prometheus service (e.g. localhost:9090/api/v1/query)"
  echo "  PROMETHEUS_USER - The username for running PromQL queries"
  echo "  PROMETHEUS_PASS - The password for running PromQL queries"
  echo
  echo "Optional environment variables:"
  echo "  PROMETHEUS_TENANTID - The tenant ID for running PromQL queries"
}

if [ "${1}" == "-h" ]; then
  usage
  exit 0
fi

configFile="${1:-/etc/config/config.json}"
if [ ! -f "${configFile}" ]; then
  echo "Config file not found: ${configFile}" >&2
  exit 2
fi
query=$(jq -r '.query // ""' "${configFile}" | envsubst)
metrics=$(fetch_metrics "${query}") || exit $?

echo "### Metrics snapshot (save the following as your baseline file) ###"
jq -n --argjson m "${metrics}" --arg q "${query}" '{
  query: $q,
  totalMetrics: ($m | length),
  totalSeries: ([$m[]] | add // 0),
  metrics: ($m | to_entries | sort_by(.key) | from_entries)
}' | yq -p json -o yaml
echo "### Metrics snapshot end ###"
