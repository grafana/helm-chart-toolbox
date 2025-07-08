#!/usr/bin/env bash

createKindCluster() {
  local testPlan=$1
  clusterName=$(getClusterName "${testPlan}")

  listClustersCommand=(kind get clusters)
  createClusterCommand=(kind create cluster --name "${clusterName}")

  clusterConfig=$(yq eval '.cluster.config // ""' "${testPlan}")
  clusterConfigFile=$(yq eval '.cluster.configFile // ""' "${testPlan}")
  if [ -n "${clusterConfig}" ]; then
    configFile=$(mktemp /tmp/kind-cluster-config.yaml.XXXXXX)
    trap 'rm -f "${configFile}"' EXIT  # Ensure the temporary file is removed on exit
    echo "${clusterConfig}" > "${configFile}"
    createClusterCommand+=(--config "${configFile}")
  elif [ -f "${clusterConfigFile}" ]; then
    createClusterCommand+=(--config "${clusterConfigFile}")
  fi

  if ! "${listClustersCommand[@]}" | grep -q "${clusterName}"; then
    echo "${createClusterCommand[@]}"
    "${createClusterCommand[@]}"
  fi
}

deleteKindCluster() {
  local testPlan=$1
  clusterName=$(yq eval '.name + "-test-cluster"' "${testPlan}")
  deleteClusterCommand=(kind delete cluster --name "${clusterName}")

  if ! "${deleteClusterCommand[@]}"; then
    # Sometimes it just needs a minute and it'll work the second time.
    # This has to do with something related to Beyla being installed and its eBPF hooks into the node.
    sleep 60
    "${deleteClusterCommand[@]}"
  fi
}
