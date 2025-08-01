#!/usr/bin/env bash

createKindCluster() {
  local testPlan=$1
  testDir="$(dirname "${testPlan}")"
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
  elif [ -n "${clusterConfigFile}" ]; then
    clusterConfigFile=$(realpath "${testDir}/${clusterConfigFile}")
    if [ ! -f "${clusterConfigFile}" ]; then
      echo "Cluster config file ${clusterConfigFile} does not exist."
      exit 1
    fi
    createClusterCommand+=(--config "${clusterConfigFile}")
  fi

  if ! "${listClustersCommand[@]}" | grep -q "${clusterName}"; then
    echo "${createClusterCommand[@]}"
    "${createClusterCommand[@]}"
  fi
}

deleteKindCluster() {
  local testPlan=$1
  clusterName=$(getClusterName "${testPlan}")
  deleteClusterCommand=(kind delete cluster --name "${clusterName}")

  totalAttempts=30
  for attempt in $(seq 1 "${totalAttempts}"); do
    if "${deleteClusterCommand[@]}"; then
      break
    elif [ "${attempt}" -eq "${totalAttempts}" ]; then
      echo "Failed to delete cluster ${clusterName} after 30 attempts."
      exit 1
    fi
    # Sometimes it can take a few attempts.
    # This has to do with something related to Beyla being installed and its eBPF hooks into the node.
    echo "Attempt ${attempt} to delete cluster ${clusterName} failed. Retrying..."
    sleep 10
  done
}
