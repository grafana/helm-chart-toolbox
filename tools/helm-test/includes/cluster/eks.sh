#!/usr/bin/env bash

createEKSCluster() {
  local testPlan=$1
  testDir="$(dirname "${testPlan}")"
  clusterName=$(getClusterName "${testPlan}")

  getClusterCommand=(eksctl get cluster --name "${clusterName}")
  createClusterCommand=(eksctl create cluster --config-file)

  clusterConfig=$(yq eval '.cluster.config // ""' "${testPlan}")
  clusterConfigFile=$(yq eval '.cluster.configFile // ""' "${testPlan}")
  if [ -n "${clusterConfig}" ]; then
    clusterConfigFile=$(mktemp /tmp/eks-cluster-config.yaml.XXXXXX)
    trap 'rm -f "${clusterConfigFile}"' EXIT  # Ensure the temporary file is removed on exit
    echo "${clusterConfig}" > "${clusterConfigFile}"
    createClusterCommand+=(--config-file "${clusterConfigFile}")
  elif [ -n "${clusterConfigFile}" ]; then
    clusterConfigFile=$(realpath "${testDir}/${clusterConfigFile}")
    if [ ! -f "${clusterConfigFile}" ]; then
      echo "Cluster config file ${clusterConfigFile} does not exist."
      exit 1
    fi
  fi

  if ! "${getClusterCommand[@]}" 2>/dev/null ; then
    echo "${createClusterCommand[@]}" <(yq eval ".metadata.name=\"${clusterName}\"" "${clusterConfigFile}")
    "${createClusterCommand[@]}" <(yq eval ".metadata.name=\"${clusterName}\"" "${clusterConfigFile}")
  fi
}

deleteEKSCluster() {
  local testPlan=$1
  clusterName=$(getClusterName "${testPlan}")

  getClusterCommand=(eksctl get cluster --name "${clusterName}")

  # The `--disable-nodegroup-eviction` flag is used to prevent hanging on an unevictable pod when using nodegroups.
  # See https://github.com/eksctl-io/eksctl/issues/6287#issuecomment-1429179939 for more information.
  deleteClusterCommand=(eksctl delete cluster --name "${clusterName}" --disable-nodegroup-eviction)

  if "${getClusterCommand[@]}" 2>/dev/null ; then
    echo "${deleteClusterCommand[@]}"
    "${deleteClusterCommand[@]}"
  fi
}
