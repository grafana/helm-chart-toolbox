#!/usr/bin/env bash

# fetch_metrics runs the PromQL query and prints, on stdout, a JSON object mapping
# each metric name to the number of series returned for it, e.g. {"up":3,"go_info":1}.
# All diagnostics are written to stderr so the stdout capture stays clean.
function fetch_metrics {
  local query="${1}"

  if [ -z "${PROMETHEUS_URL}" ]; then
    echo "PROMETHEUS_URL is not defined. Unable to run PromQL queries!" >&2
    return 2
  fi

  echo "Running PromQL query: ${PROMETHEUS_URL}?query=${query}..." >&2
  local additionalRequestOptions=()
  if [ -n "${PROMETHEUS_TENANTID}" ]; then
    additionalRequestOptions=("-H" "X-Scope-OrgID: ${PROMETHEUS_TENANTID}")
  fi

  local result status
  result=$(curl -skX POST "${additionalRequestOptions[@]}" -u "${PROMETHEUS_USER}:${PROMETHEUS_PASS}" "${PROMETHEUS_URL}" --data-urlencode "query=${query}")
  status=$(echo "${result}" | jq -r '.status // "error"')
  if [ "${status}" != "success" ]; then
    echo "Query failed!" >&2
    echo "Response: ${result}" >&2
    return 3
  fi

  # Group the returned series by their metric name label and count each group.
  echo "${result}" | jq -c --arg nl "__name__" '
    [.data.result[] | .metric[$nl] // "__unnamed__"]
    | group_by(.)
    | map({key: .[0], value: length})
    | from_entries'
}
