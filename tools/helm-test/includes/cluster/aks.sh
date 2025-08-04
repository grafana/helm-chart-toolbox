#!/usr/bin/env bash

createAKSCluster() {
  local testPlan=$1
  clusterName=$(getClusterName "${testPlan}")

  listClustersCommand=(az aks list --query '[].name')
  createClusterCommand=(az aks create --yes --name "${clusterName}")
  getCredentialsCommand=(az aks get-credentials --name "${clusterName}")

  if ! "${listClustersCommand[@]}" | grep -q "${clusterName}"; then
    argsString="$(yq eval -r -o=json '.cluster.args | join(" ")' "${testPlan}")"
    IFS=" " read -r -a args <<< "${argsString}"
    createClusterCommand+=("${args[@]}")
    echo "${createClusterCommand[@]}"
    "${createClusterCommand[@]}"
  fi
  echo "${getCredentialsCommand[@]}"
  "${getCredentialsCommand[@]}"
}

deleteAKSCluster() {
  local testPlan=$1
  clusterName=$(getClusterName "${testPlan}")

  listClustersCommand=(az aks list --query '[].name')
  deleteClusterCommand=(az aks delete --yes --name "${clusterName}")

  if "${listClustersCommand[@]}" | grep -q "${clusterName}"; then
    echo "${deleteClusterCommand[@]}"
    "${deleteClusterCommand[@]}"
  fi
}
