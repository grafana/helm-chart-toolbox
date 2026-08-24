#!/usr/bin/env bash

requireCommand() {
  local cmd=$1
  if ! command -v "${cmd}" > /dev/null 2>&1; then
    echo "Required command '${cmd}' is not installed or not in PATH. Please install it and try again." >&2
    exit 1
  fi
}

getClusterName() {
  local testPlan=$1
  testDir=$(dirname "$(readlink -f "${testPlan}")")
  clusterName=$(yq eval '.cluster.name // .name + "-test-cluster"' "${testPlan}")
  appendRandomNumber=$(yq eval '.cluster.appendRandomNumber // false' "${testPlan}")
  if [ "${appendRandomNumber}" = "true" ]; then
    randomNumberFile="${testDir}/.random"
    if [ -f "${randomNumberFile}" ]; then
      randomNumber=$(cat "${randomNumberFile}")
    else
      randomNumber=$(shuf -i 100000-999999 -n 1)
      echo "${randomNumber}" > "${randomNumberFile}"
    fi
    clusterName="${clusterName}-${randomNumber}"
  fi
  echo "${clusterName}"
}

getRandomNumber() {
  local testPlan=$1
  testDir=$(dirname "$(readlink -f "${testPlan}")")
  appendRandomNumber=$(yq eval '.cluster.appendRandomNumber // false' "${testPlan}")
  randomNumber=""
  if [ "${appendRandomNumber}" = "true" ]; then
    randomNumberFile="${testDir}/.random"
    if [ -f "${randomNumberFile}" ]; then
      randomNumber=$(cat "${randomNumberFile}")
    else
      randomNumber=$(shuf -i 100000-999999 -n 1)
      echo "${randomNumber}" > "${randomNumberFile}"
    fi
  fi
  echo "${randomNumber}"
}

redactSecrets() {
  local keys='(password|passwd|pwd|token|secret|api[_-]?key|apikey|access[_-]?key|secret[_-]?key|client[_-]?secret|credential|bearer)'
  sed -E \
    -e "s/(${keys}[\"']?[[:space:]]*[:=][[:space:]]*)([\"'])[^\"']*\3/\1\3[REDACTED]\3/gI" \
    -e "s/(${keys}[\"']?[[:space:]]*[:=][[:space:]]*)[^[:space:],;\"']+/\1[REDACTED]/gI"
}
