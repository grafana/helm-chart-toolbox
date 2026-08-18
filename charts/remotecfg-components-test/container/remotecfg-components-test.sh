#!/bin/bash
# Assert that each collector is running (at least) the Alloy components Fleet
# Management holds for its cluster.
#
# Input:
#   $1               checks.json — {"checks":[{"role":..,"namespace":..,"selector":..}]}
#   EXPECTED_<ROLE>  env var (role upper-cased) — space-separated expected component types
#
# One evaluation pass: exit 0 if every check passes, 1 otherwise. The test Pod
# wraps this in the attempts/delay retry loop, so no internal retry here.

set -uo pipefail

usage() {
  echo "USAGE: remotecfg-components-test.sh checks.json"
  echo "Assert collectors run the Alloy components Fleet Management holds for the cluster."
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi
if [ -z "${1:-}" ]; then
  usage
  exit 1
fi

checksFile="${1}"
port="${ALLOY_PORT:-12345}"
api="/api/v0/web/remotecfg/components"

kubectl=$(command -v kubectl)
if [ -n "${KUBERNETES_VERSION:-}" ] && command -v "kubectl-${KUBERNETES_VERSION}" >/dev/null 2>&1; then
  kubectl=$(command -v "kubectl-${KUBERNETES_VERSION}")
fi

pod_module_components() {
  local ip="${1}" moduleID="${2}" url body
  if [ -z "${moduleID}" ]; then
    url="http://${ip}:${port}${api}"
  else
    url="http://${ip}:${port}/api/v0/web/remotecfg/modules/${moduleID}/components"
  fi
  body=$(curl --silent --fail --max-time 10 "${url}") || return 0
  echo "${body}" | jq -r '.[].name'
  echo "${body}" | jq -r '.[].createdModuleIDs[]? // empty' | sort -u | while read -r child; do
    [ -z "${child}" ] && continue
    pod_module_components "${ip}" "${child}"
  done
}

# Print the IPs (one per line) of the Running pods matching the selector.
running_pod_ips() {
  local namespace="${1}" selector="${2}"
  "${kubectl}" get pods --namespace "${namespace}" --selector "${selector}" \
    --field-selector=status.phase=Running \
    --output 'jsonpath={range .items[*]}{.status.podIP}{"\n"}{end}' 2>/dev/null
}

# Print the running Alloy component set (one name per line) for a single pod,
# including the components of any nested modules.
pod_components() {
  local ip="${1}"
  pod_module_components "${ip}" "" |
    grep -E '^[a-z][a-z0-9]*(\.[a-z0-9_]+)+$' | sort -u
}

exitCode=0
count=$(jq '.checks | length' "${checksFile}")
for idx in $(seq 0 $((count - 1))); do
  role=$(jq -r ".checks[${idx}].role" "${checksFile}")
  namespace=$(jq -r ".checks[${idx}].namespace // \"default\"" "${checksFile}")
  selector=$(jq -r ".checks[${idx}].selector" "${checksFile}")

  varName="EXPECTED_$(echo "${role}" | tr '[:lower:]' '[:upper:]')"
  expected="${!varName:-}"
  if [ -z "${expected// /}" ]; then
    echo "[${role} ${selector}] FAIL: expected component set is empty (Fleet Management holds no ${role} pipeline for this cluster)"
    exitCode=1
    continue
  fi

  read -ra expectedArr <<<"${expected}"

  ips=$(running_pod_ips "${namespace}" "${selector}")
  if [ -z "${ips//[[:space:]]/}" ]; then
    echo "[${role} ${selector}] FAIL: no running pods match selector"
    exitCode=1
    continue
  fi

  checkFailed=0
  podCount=0
  while read -r ip; do
    [ -z "${ip}" ] && continue
    podCount=$((podCount + 1))
    running=$(pod_components "${ip}")
    missing=""
    for component in "${expectedArr[@]}"; do
      grep -qxF "${component}" <<<"${running}" || missing="${missing} ${component}"
    done
    if [ -n "${missing// /}" ]; then
      echo "[${role} ${selector} ${ip}] FAIL: missing:${missing}"
      checkFailed=1
    fi
  done <<<"${ips}"

  if [ "${checkFailed}" -eq 0 ]; then
    echo "[${role} ${selector}] OK: all ${podCount} pods running all ${#expectedArr[@]} expected components"
  else
    exitCode=1
  fi
done

if [ "${exitCode}" -eq 0 ]; then
  echo "All expected components present"
fi
exit "${exitCode}"
