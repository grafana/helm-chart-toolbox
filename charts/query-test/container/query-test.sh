#!/bin/bash

scriptDir=$(dirname "$(readlink -f "$0")")
source "${scriptDir}/common.sh"

usage() {
  echo "USAGE: query-test.sh queries.json"
  echo "Run a set of queries against Prometheus, Loki, or Tempo"
  echo
  echo "Required environment variables:"
  echo "  If using any PromQL queries:"
  echo "  PROMETHEUS_URL - The query URL for your Prometheus service (e.g. localhost:9090/api/v1/query)"
  echo "  PROMETHEUS_TENANTID - The tenant ID for running PromQL queries"
  echo "  PROMETHEUS_USER - The username for running PromQL queries"
  echo "  PROMETHEUS_PASS - The password for running PromQL queries"
  echo
  echo "  If using any LogQL queries:"
  echo "  LOKI_URL - The query URL for your Loki service (e.g. localhost:9090/api/v1/query)"
  echo "  LOKI_TENANTID - The tenant ID for running LogQL queries"
  echo "  LOKI_USER - The username for running LogQL queries"
  echo "  LOKI_PASS - The password for running LogQL queries"
  echo
  echo "  If using any TraceQL queries:"
  echo "  TEMPO_URL - The search URL for your Tempo service (e.g. localhost:9090/api/search)"
  echo "  TEMPO_USER - The username for running TraceQL queries"
  echo "  TEMPO_PASS - The password for running TraceQL queries"
  echo
  echo "  If using any profile queries:"
  echo "  PROFILECLI_URL - The URL for your Pyroscope service (e.g. localhost:4040)"
  echo "  PROFILECLI_USERNAME - The username for running Pyroscope queries"
  echo "  PROFILECLI_PASSWORD - The password for running Pyroscope queries"
  echo
  echo "Optional environment variables:"
  echo "  If using any PromQL queries:"
  echo "  PROMETHEUS_TENANTID - The tenant ID for running PromQL queries"
  echo
  echo "queries.json is the queries file, and should be in the format:"
  echo '{"queries": [<query>]}'
  echo
  echo "Each query has this format:"
  echo '{'
  echo '  "query": "<query string>",'
  echo '  "type": "[promql (default)|logql|traceql]|[pyroql]",'
  echo '}'
  echo
  echo 'You can add an "expect" section to the query to validate the returned value'
  echo '  "expect": {'
  echo '    "operator": "[<, <=, ==, !=, =>, >]",'
  echo '    "value": <expected value>'
  echo '  }'
}

if [ -z "${1}" ] || [ "${1}" == "-h" ]; then
  usage
  exit 0
fi

QUERIES_FILE="${1}"
if [ ! -f "${QUERIES_FILE}" ]; then
  echo "Queries file not found: ${QUERIES_FILE}"
  usage
  exit 1
fi

count=$(jq -r ".queries | length-1" "${QUERIES_FILE}")
for i in $(seq 0 "${count}"); do
  query=$(jq -r --argjson i "${i}" '.queries[$i].query' "${QUERIES_FILE}" | envsubst)
  type=$(jq -r --argjson i "${i}" '.queries[$i] | .type // "promql"' "${QUERIES_FILE}")
  expectedCount=$(jq -r --argjson i "${i}" '.queries[$i].expect.count // empty | tostring' "${QUERIES_FILE}")
  expectedValue=$(jq -r --argjson i "${i}" '.queries[$i].expect.value // empty | tostring' "${QUERIES_FILE}")
  expectedOperator=$(jq -r --argjson i "${i}" '.queries[$i].expect | .operator // "=="' "${QUERIES_FILE}")

  case "${type}" in
    promql)
      if ! metrics_query "${query}" "${expectedCount}" "${expectedValue}" "${expectedOperator}"; then
        exit 1
      fi
      ;;
    logql)
      if ! logs_query "${query}"; then
        exit 1
      fi
      ;;
    traceql)
      if ! traces_query "${query}"; then
        exit 1
      fi
      ;;
    pyroql)
      if ! profiles_query "${query}"; then
        exit 1
      fi
      ;;
    *)
      echo "Query type ${type} is not yet supported in this test"
      exit 1
      ;;
  esac
done

echo "All queries passed!"
