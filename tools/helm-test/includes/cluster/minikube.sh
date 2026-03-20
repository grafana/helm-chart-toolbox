#!/usr/bin/env bash

createMinikubeCluster() {
  local testPlan=$1
  command=(minikube start)

  driver="$(yq eval -r '.cluster.driver' "${testPlan}")"
  if [ "${driver}" != "null" ] && [ -n "${driver}" ]; then
    command+=("--driver=${driver}")
  fi

  argsString="$(yq eval -r -o=json '.cluster.args // [] | join(" ")' "${testPlan}")"
  if [ "${argsString}" != "null" ] && [ -n "${argsString}" ]; then
    IFS=" " read -r -a args <<< "${argsString}"
    command+=("${args[@]}")
  fi

  if ! minikube status; then
    echo "${command[@]}"
    "${command[@]}"
  fi
}

deleteMinikubeCluster() {
  if minikube status; then
    minikube delete
  fi
}
