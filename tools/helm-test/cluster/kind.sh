#!/usr/bin/env bash

createKindCluster() {
  local testPlan=$1
  clusterName=$(yq eval '.name + "-test-cluster"' "${testPlan}")
  clusterConfig=$(yq eval '.cluster.config // ""' "${testPlan}")
  clusterConfigFile=$(yq eval '.cluster.configFile // ""' "${testPlan}")

  command=(kind create cluster --name "${clusterName}")
  if [ -n "${clusterConfig}" ]; then
    configFile=$(mktemp /tmp/kind-cluster-config.yaml.XXXXXX)
    trap 'rm -f "${configFile}"' EXIT  # Ensure the temporary file is removed on exit
    echo "${clusterConfig}" > "${configFile}"
    command+=(--config "${configFile}")
  elif [ -f "${clusterConfigFile}" ]; then command+=(--config "${clusterConfigFile}")
  fi
  if ! kind get clusters | grep -q "${clusterName}"; then
    echo "${command[@]}"
    "${command[@]}"
  fi
}

deleteKindCluster() {
  local testPlan=$1
  clusterName=$(yq eval '.name + "-test-cluster"' "${testPlan}")

  if ! kind delete cluster --name "${clusterName}"; then
    # Sometimes it just needs a minute and it'll work the second time.
    # This has to do with something related to Beyla being installed and its eBPF hooks into the node.
    sleep 60
    kind delete cluster --name "${clusterName}"
  fi
}
