#!/bin/bash

scriptDir=$(dirname "$(readlink -f "$0")")
source "${scriptDir}/common.sh"

usage() {
  echo "USAGE: metrics-snapshot.sh <generate|compare> [config.json] [baseline.yaml]"
  echo "Run a PromQL query and snapshot the metric names and series counts it returns."
  echo
  echo "Modes:"
  echo "  generate - Run the query and print a YAML snapshot of the metric names and"
  echo "             their series counts. Use this output as the baseline file."
  echo "  compare  - Run the query and compare the result against a baseline snapshot,"
  echo "             reporting added, missing, and changed metrics."
  echo
  echo "Arguments:"
  echo "  config.json   - The test configuration (default: /etc/config/config.json)"
  echo "  baseline.yaml - The baseline snapshot to compare against, for the compare"
  echo "                  mode (default: /etc/baseline/baseline.yaml)"
  echo
  echo "Required environment variables:"
  echo "  PROMETHEUS_URL - The query URL for your Prometheus service (e.g. localhost:9090/api/v1/query)"
  echo "  PROMETHEUS_USER - The username for running PromQL queries"
  echo "  PROMETHEUS_PASS - The password for running PromQL queries"
  echo
  echo "Optional environment variables:"
  echo "  PROMETHEUS_TENANTID - The tenant ID for running PromQL queries"
  echo
  echo "config.json has this format:"
  echo '{'
  echo '  "query": "<PromQL query string>",'
  echo '  "nameLabel": "__name__",'
  echo '  "reportThreshold": 1,'
  echo '  "failThreshold": 20,'
  echo '  "failOnNewMetrics": true,'
  echo '  "failOnMissingMetrics": true'
  echo '}'
}

mode="${1}"
if [ -z "${mode}" ] || [ "${mode}" == "-h" ]; then
  usage
  exit 0
fi

configFile="${2:-/etc/config/config.json}"
baselineFile="${3:-/etc/baseline/baseline.yaml}"

if [ ! -f "${configFile}" ]; then
  echo "Config file not found: ${configFile}"
  usage
  exit 1
fi

query=$(jq -r '.query // ""' "${configFile}" | envsubst)
nameLabel=$(jq -r '.nameLabel // "__name__"' "${configFile}")
reportThreshold=$(jq -r '.reportThreshold // 1' "${configFile}")
failThreshold=$(jq -r '.failThreshold // 20' "${configFile}")
failOnNewMetrics=$(jq -r '.failOnNewMetrics // true' "${configFile}")
failOnMissingMetrics=$(jq -r '.failOnMissingMetrics // true' "${configFile}")

if [ -z "${query}" ]; then
  echo "No query defined in ${configFile}"
  exit 1
fi

case "${mode}" in
  generate)
    metrics=$(fetch_metrics "${query}" "${nameLabel}") || exit 3
    echo "### Metrics snapshot (save the following as your baseline file) ###"
    emit_snapshot "${metrics}" "${query}"
    ;;
  compare)
    metrics=$(fetch_metrics "${query}" "${nameLabel}") || exit 3
    run_compare "${metrics}" "${baselineFile}" "${reportThreshold}" "${failThreshold}" "${failOnNewMetrics}" "${failOnMissingMetrics}"
    exit $?
    ;;
  *)
    echo "Unknown mode: ${mode}"
    usage
    exit 1
    ;;
esac
