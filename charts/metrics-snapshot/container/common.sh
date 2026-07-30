#!/usr/bin/env bash

# Exit codes used throughout the metrics-snapshot test:
#   0 - success (snapshot generated, or comparison within thresholds)
#   1 - definitive failure (comparison exceeded a failing threshold). Do not retry.
#   3 - transient failure (query error, no connection, etc). Safe to retry.

# fetch_metrics runs the PromQL query and prints, on stdout, a JSON object mapping
# each metric name to the number of series returned for it, e.g. {"up":3,"go_info":1}.
# All diagnostics are written to stderr so the stdout capture stays clean.
function fetch_metrics {
  local query="${1}"
  local nameLabel="${2}"

  if [ -z "${PROMETHEUS_URL}" ]; then
    echo "PROMETHEUS_URL is not defined. Unable to run PromQL queries!" >&2
    return 3
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
  echo "${result}" | jq -c --arg nl "${nameLabel}" '
    [.data.result[] | .metric[$nl] // "__unnamed__"]
    | group_by(.)
    | map({key: .[0], value: length})
    | from_entries'
}

# emit_snapshot prints a stable, human-readable YAML snapshot for the given metrics
# map. The metric names are sorted so the file produces clean diffs when committed.
function emit_snapshot {
  local metrics="${1}"
  local query="${2}"

  jq -n --argjson m "${metrics}" --arg q "${query}" '{
    query: $q,
    totalMetrics: ($m | length),
    totalSeries: ([$m[]] | add // 0),
    metrics: ($m | to_entries | sort_by(.key) | from_entries)
  }' | yq -p json -o yaml
}

# run_compare compares the current metrics map against a baseline snapshot file and
# prints a report of the differences. It returns 1 when a failing threshold is
# exceeded and 0 otherwise.
function run_compare {
  local current="${1}"
  local baselineFile="${2}"
  local reportThreshold="${3}"
  local failThreshold="${4}"
  local failOnNewMetrics="${5}"
  local failOnMissingMetrics="${6}"

  if [ ! -f "${baselineFile}" ]; then
    echo "Baseline file not found: ${baselineFile}" >&2
    return 3
  fi

  local baseMetrics
  baseMetrics=$(yq -p yaml -o json '.metrics // {}' "${baselineFile}")

  local analysis
  analysis=$(jq -n \
    --argjson base "${baseMetrics}" \
    --argjson cur "${current}" \
    --argjson reportT "${reportThreshold}" \
    --argjson failT "${failThreshold}" \
    --argjson failNew "${failOnNewMetrics}" \
    --argjson failMissing "${failOnMissingMetrics}" '
    def r: (. * 100 | round) / 100;
    def abs: if . < 0 then -. else . end;
    ($base | keys) as $bk |
    ($cur | keys) as $ck |
    ($ck - $bk | sort) as $added |
    ($bk - $ck | sort) as $missing |
    [ $bk[] | select($cur[.] != null) ] as $common |
    [ $common[] | . as $k |
      $base[$k] as $b | $cur[$k] as $c |
      (if $b == 0 then (if $c == 0 then 0 else 100 end) else (($c - $b) / $b * 100) end) as $pct |
      {name: $k, base: $b, cur: $c, pct: ($pct | r), abspct: ($pct | abs)} ] as $all |
    ([$base[]] | add // 0) as $baseSeries |
    ([$cur[]] | add // 0) as $curSeries |
    (if $baseSeries == 0 then (if $curSeries == 0 then 0 else 100 end) else (($curSeries - $baseSeries) / $baseSeries * 100) end) as $seriesPct |
    {
      summary: {
        baseMetrics: ($bk | length),
        curMetrics: ($ck | length),
        baseSeries: $baseSeries,
        curSeries: $curSeries,
        seriesPct: ($seriesPct | r)
      },
      added: $added,
      missing: $missing,
      reported: ([ $all[] | select(.abspct > $reportT) ] | sort_by(-.abspct)),
      failed: ([ $all[] | select(.abspct > $failT) ] | sort_by(-.abspct)),
      seriesFailed: (($seriesPct | abs) > $failT),
      fail: (
        (($failNew == true) and (($added | length) > 0)) or
        (($failMissing == true) and (($missing | length) > 0)) or
        (([ $all[] | select(.abspct > $failT) ] | length) > 0) or
        (($seriesPct | abs) > $failT)
      )
    }')

  echo "Comparing current metrics against baseline: ${baselineFile}"
  echo "  Reporting threshold: ${reportThreshold}%   Failing threshold: ${failThreshold}%"
  echo
  echo "${analysis}" | jq -r '.summary |
    "Summary: metrics \(.baseMetrics) -> \(.curMetrics), series \(.baseSeries) -> \(.curSeries) (\(.seriesPct)% change)"'
  echo

  echo "Added metrics (present now, absent in baseline):"
  if [ "$(echo "${analysis}" | jq '.added | length')" -eq 0 ]; then
    echo "  (none)"
  else
    echo "${analysis}" | jq -r '.added[] | "  + \(.)"'
  fi
  echo

  echo "Missing metrics (present in baseline, absent now):"
  if [ "$(echo "${analysis}" | jq '.missing | length')" -eq 0 ]; then
    echo "  (none)"
  else
    echo "${analysis}" | jq -r '.missing[] | "  - \(.)"'
  fi
  echo

  echo "Changed metrics (over ${reportThreshold}% change in series count):"
  if [ "$(echo "${analysis}" | jq '.reported | length')" -eq 0 ]; then
    echo "  (none)"
  else
    echo "${analysis}" | jq -r '.reported[] |
      "  ~ \(.name): \(.base) -> \(.cur) (\(if .pct > 0 then "+" else "" end)\(.pct)%)"'
  fi
  echo

  if [ "$(echo "${analysis}" | jq -r '.fail')" == "true" ]; then
    echo "RESULT: FAIL"
    echo "${analysis}" | jq -r '
      ([if (.added | length) > 0 then "  - \(.added | length) added metric(s)" else empty end] +
       [if (.missing | length) > 0 then "  - \(.missing | length) missing metric(s)" else empty end] +
       [if (.failed | length) > 0 then "  - \(.failed | length) metric(s) changed more than the failing threshold" else empty end] +
       [if .seriesFailed then "  - total series count changed more than the failing threshold" else empty end])[]'
    return 1
  fi

  echo "RESULT: PASS"
  return 0
}
