#!/bin/bash

scriptDir=$(dirname "$(readlink -f "$0")")
source "${scriptDir}/common.sh"

# Exit codes used throughout the metrics-snapshot test:
#   0 - success (comparison within thresholds, or skipped)
#   1 - test failure (comparison exceeded a failing threshold). The caller may retry,
#       since metrics can still be arriving shortly after deploy.
#   2 - systemic failure (missing required fields). Can not retry.
#   3 - transient failure (query error, no connection, etc). Safe to retry.

usage() {
  echo "USAGE: compare.sh [config.json] [baseline.yaml]"
  echo "Run a PromQL query and compare the result against a baseline snapshot,"
  echo "reporting added, missing, and changed metrics."
  echo
  echo "Arguments:"
  echo "  config.json   - The test configuration (default: /etc/config/config.json)"
  echo "  baseline.yaml - The baseline snapshot to compare against (default: /etc/baseline/baseline.yaml)"
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
baselineFile="${2:-/etc/baseline/baseline.yaml}"
if [ ! -f "${baselineFile}" ]; then
  echo "Baseline file not found: ${baselineFile}" >&2
  exit 2
fi

query=$(jq -r '.query // ""' "${configFile}" | envsubst)
reportThreshold=$(jq -r '.reportThreshold // 1' "${configFile}")
failThreshold=$(jq -r '.failThreshold // 20' "${configFile}")
failOnNewMetrics=$(jq -r '.failOnNewMetrics // true' "${configFile}")
failOnMissingMetrics=$(jq -r '.failOnMissingMetrics // true' "${configFile}")

metrics=$(fetch_metrics "${query}") || exit $?

# If the baseline recorded the query it was generated from, and it differs from the
# query we just ran, the two snapshots are not comparable. Skip rather than report
# spurious differences.
baselineQuery=$(yq '.query // ""' "${baselineFile}")
if [ -n "${baselineQuery}" ] && [ "${baselineQuery}" != "${query}" ]; then
  echo "The baseline was generated with a different query; skipping comparison."
  echo "  Baseline query: ${baselineQuery}"
  echo "  Current query:  ${query}"
  echo "Regenerate the baseline file to compare against the new query."
  echo "RESULT: SKIPPED"
  exit 0
fi

baseMetrics=$(yq -p yaml -o json '.metrics // {}' "${baselineFile}")

analysis=$(jq -n \
  --argjson base "${baseMetrics}" \
  --argjson cur "${metrics}" \
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
  exit 1
fi

echo "RESULT: PASS"
