#!/usr/bin/env bash

createK3dCluster() {
  local testPlan=$1
  requireCommand k3d
  testDir="$(dirname "${testPlan}")"
  clusterName=$(getClusterName "${testPlan}")

  listClustersCommand=(k3d cluster list --output json)
  createClusterCommand=(k3d cluster create "${clusterName}")

  clusterConfig=$(yq eval '.cluster.config // ""' "${testPlan}")
  clusterConfigFile=$(yq eval '.cluster.configFile // ""' "${testPlan}")
  if [ -n "${clusterConfig}" ]; then
    configFile=$(mktemp /tmp/k3d-cluster-config.yaml.XXXXXX)
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

  if ! "${listClustersCommand[@]}" | yq eval -p=json '.[].name' | grep -qx "${clusterName}"; then
    echo "${createClusterCommand[@]}"
    "${createClusterCommand[@]}"
  fi
}

deleteK3dCluster() {
  local testPlan=$1
  requireCommand k3d
  clusterName=$(getClusterName "${testPlan}")
  deleteClusterCommand=(k3d cluster delete "${clusterName}")

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
