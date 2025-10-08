#!/bin/bash

usage() {
  echo "USAGE: kubernetes-objects-test.sh checks.json"
  echo "Check for the existence of Kubernetes objects in a cluster."
  echo
  echo "Optional environment variables:"
  echo "  KUBERNETES_VERSION - The version of Kubernetes cluster, used to determine the version of kubectl to use (default: latest GA)"
  echo
  echo "checks.json is the checks file, and should be in the format:"
  echo '{"checks": [<check>]}'
  echo
  echo "Each check has this format:"
  echo '{'
  echo '  "kind": "<Object kind>",           # Required. For example: "pod", "deployment", "service", etc...'
  echo '  "name": "<Object name>",           # Optional, if not provided all objects of the kind will be returned.'
  echo '  "labels": {"key": "value"},        # Optional, apply a label selector to the lookup.'
  echo '  "namespace": "<Object namespace>", # Optional, if not provided the default namespace will be used.'
  echo '  "expect": {}                       # Optional, a list of expectations. If empty, will check that at least one object of the kind exists.'
  echo '}'
  echo
  echo 'You can add an "expect" section to the check to validate the returned value'
  echo '  "expect": {'
  echo '    "count": <number>          # Optional, if provided will check that the number of objects returned matches this value.'
  echo '  }'
}

if [ -z "${1}" ] || [ "${1}" == "-h" ]; then
  usage
  exit 0
fi

VERBOSE=${VERBOSE:-false}

CHECKS_FILE="${1}"
if [ ! -f "${CHECKS_FILE}" ]; then
  echo "Checks file not found: ${CHECKS_FILE}"
  usage
  exit 1
fi

KUBECTL=$(which kubectl)
if [ -n "${KUBERNETES_VERSION}" ]; then
  VERSIONED_KUBECTL=$(which "kubectl-${KUBERNETES_VERSION}")
  if [ -n "${VERSIONED_KUBECTL}" ]; then
    KUBECTL="${VERSIONED_KUBECTL}"
  else
    echo "kubectl for version ${KUBERNETES_VERSION} not found. Defaulting to latest kubectl."
  fi
fi

function existsExpectation() {
  local result="$1"

  kind=$(echo "${result}" | jq -r '.kind')
  if [ "${kind}" == "List" ]; then
    actualCount=$(echo "${result}" | jq -r '.items | length')
    if [ "${actualCount}" -eq 0 ]; then
      echo "  Expected at least one, but found none."
      return 1
    fi
  fi

  return 0
}

function countExpectation() {
  local result="$1"
  local expectedCount="$2"

  kind=$(echo "${result}" | jq -r '.kind')
  if [ "${kind}" == "List" ]; then
    actualCount=$(echo "${result}" | jq -r '.items | length')
  else
    actualCount=1
  fi

  if [ "${actualCount}" -ne "${expectedCount}" ]; then
    echo "  Expected ${expectedCount}, but found ${actualCount}."
    return 1
  fi

  return 0
}

count=$(jq -r ".checks | length-1" "${CHECKS_FILE}")
for i in $(seq 0 "${count}"); do
  kind=$(jq -r --argjson i "${i}" '.checks[$i].kind | ascii_downcase' "${CHECKS_FILE}" | envsubst)
  name=$(jq -r --argjson i "${i}" '.checks[$i].name // ""' "${CHECKS_FILE}" | envsubst)
  labels=$(jq -r --argjson i "${i}" '.checks[$i].labels // {} | to_entries | map("\(.key)=\(.value | tostring)") | join(",")' "${CHECKS_FILE}" | envsubst)
  namespace=$(jq -r --argjson i "${i}" '.checks[$i].namespace // ""' "${CHECKS_FILE}" | envsubst)

  subject="${kind}"
  command=("${KUBECTL}" get "${kind}" --ignore-not-found=false --output=json)
  if [ -n "${name}" ]; then
    subject+=" named ${name}"
    command+=("${name}")
  fi
  if [ -n "${labels}" ]; then
    subject+=" with labels ${labels}"
    command+=("--selector" "${labels}")
  fi
  if [ -n "${namespace}" ]; then
    subject+=" in namespace ${namespace}"
    command+=("--namespace" "${namespace}")
  fi

  echo "Looking for ${subject}..."
  if [ "${VERBOSE}" == "true" ]; then
    echo "${command[@]}"
  fi
  output=$("${command[@]}" 2>/dev/null)
  if [ -z "${output}" ]; then
    if [ "${VERBOSE}" == "true" ]; then
      echo "  No ${subject} found."
    fi
    output='{"kind":"List","items":[]}'
  fi

  expectations=$(jq -r --argjson i "${i}" '.checks[$i].expect' "${CHECKS_FILE}")
  if [ "${expectations}" == "null" ]; then
    if ! existsExpectation "${output}"; then
      exit 1
    fi
  else
    countExpectation=$(jq -r --argjson i "${i}" '.checks[$i].expect.count // ""' "${CHECKS_FILE}")
    if [ -n "${countExpectation}" ]; then
      if ! countExpectation "${output}" "${countExpectation}"; then
        exit 1
      fi
    fi
  fi
done

echo "All checks passed!"
