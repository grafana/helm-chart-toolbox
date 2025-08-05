#!/usr/bin/env bash

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
