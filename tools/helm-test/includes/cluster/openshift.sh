#!/usr/bin/env bash

createOpenShiftCluster() {
  local testPlan=$1
  testDir="$(dirname "${testPlan}")"
  clusterName=$(getClusterName "${testPlan}")

  clusterInstallerFilesDir="${testDir}/${clusterName}-installer-files"

  createClusterCommand=(openshift-install create cluster --dir "${clusterInstallerFilesDir}")

  clusterConfig=$(yq eval '.cluster.config // ""' "${testPlan}")
  clusterConfigFile=$(yq eval '.cluster.configFile // ""' "${testPlan}")
  if [ ! -f "${clusterInstallerFilesDir}/auth/kubeconfig" ]; then
    mkdir -p "${clusterInstallerFilesDir}"

    if [ -n "${clusterConfig}" ]; then
      yq ".cluster.config | .metadata.name=\"${clusterName}\"" "${testPlan}" > "${clusterInstallerFilesDir}/install-config.yaml"
    elif [ -n "${clusterConfigFile}" ]; then
      clusterConfigFile=$(realpath "${testDir}/${clusterConfigFile}")
      if [ ! -f "${clusterConfigFile}" ]; then
        echo "Cluster config file ${clusterConfigFile} does not exist."
        exit 1
      fi
      yq eval ".metadata.name=\"${clusterName}\"" "${clusterConfigFile}" > "${clusterInstallerFilesDir}/install-config.yaml"
    fi

    echo "${createClusterCommand[@]}"
    "${createClusterCommand[@]}"

    ln -s "${clusterInstallerFilesDir}/auth/kubeconfig" "$(dirname "${clusterConfig}")/kubeconfig.yaml"
  fi
}

deleteOpenShiftCluster() {
  local testPlan=$1
  clusterName=$(getClusterName "${testPlan}")
  clusterInstallerFilesDir="${testDir}/${clusterName}-installer-files"

  deleteClusterCommand=(openshift-install destroy cluster --dir "${clusterInstallerFilesDir}")

  echo "${deleteClusterCommand[@]}"
  "${deleteClusterCommand[@]}"
}
