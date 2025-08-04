#!/usr/bin/env bash

createGKECluster() {
  local testPlan=$1
  clusterName=$(getClusterName "${testPlan}")

  listClustersCommand=(gcloud container clusters list --format="value(name)")
  createClusterCommand=(gcloud container clusters create "${clusterName}")

  location=$(yq eval '.cluster.location // ""' "${testPlan}")
  if [ -n "${location}" ]; then
      listClustersCommand+=(--location "${location}")
      createClusterCommand+=(--location "${location}")
  fi
  region=$(yq eval '.cluster.region // ""' "${testPlan}")
  if [ -n "${region}" ]; then
      listClustersCommand+=(--region "${region}")
      createClusterCommand+=(--region "${region}")
  fi
  zone=$(yq eval '.cluster.zone // ""' "${testPlan}")
  if [ -n "${zone}" ]; then
      listClustersCommand+=(--zone "${zone}")
      createClusterCommand+=(--zone "${zone}")
  fi

  if ! "${listClustersCommand[@]}" | grep -q "${clusterName}"; then
    argsString="$(yq eval -r -o=json '.cluster.args | join(" ")' "${testPlan}")"
    IFS=" " read -r -a args <<< "${argsString}"
    createClusterCommand+=("${args[@]}")
    echo "${createClusterCommand[@]}"
    "${createClusterCommand[@]}"
  fi
}

createGKEAutopilotCluster() {
  local testPlan=$1
  clusterName=$(getClusterName "${testPlan}")

  listClustersCommand=(gcloud container clusters list --format="value(name)")
  createClusterCommand=(gcloud container clusters create-auto "${clusterName}")

  location=$(yq eval '.cluster.location // ""' "${testPlan}")
  if [ -n "${location}" ]; then
      listClustersCommand+=(--location "${location}")
      createClusterCommand+=(--location "${location}")
  fi
  region=$(yq eval '.cluster.region // ""' "${testPlan}")
  if [ -n "${region}" ]; then
      listClustersCommand+=(--region "${region}")
      createClusterCommand+=(--region "${region}")
  fi
  zone=$(yq eval '.cluster.zone // ""' "${testPlan}")
  if [ -n "${zone}" ]; then
      listClustersCommand+=(--zone "${zone}")
      createClusterCommand+=(--zone "${zone}")
  fi

  if ! "${listClustersCommand[@]}" | grep -q "${clusterName}"; then
    argsString="$(yq eval -r -o=json '.cluster.args | join(" ")' "${testPlan}")"
    IFS=" " read -r -a args <<< "${argsString}"
    createClusterCommand+=("${args[@]}")
    echo "${createClusterCommand[@]}"
    "${createClusterCommand[@]}"
  fi
}

deleteGKECluster() {
  local testPlan=$1
  clusterName=$(getClusterName "${testPlan}")

  listClustersCommand=(gcloud container clusters list --format="value(name)")
  deleteClusterCommand=(gcloud container clusters delete "${clusterName}" --quiet)

  location=$(yq eval '.cluster.location // ""' "${testPlan}")
  if [ -n "${location}" ]; then
      listClustersCommand+=(--location "${location}")
      deleteClusterCommand+=(--location "${location}")
  fi
  region=$(yq eval '.cluster.region // ""' "${testPlan}")
  if [ -n "${region}" ]; then
      listClustersCommand+=(--region "${region}")
      deleteClusterCommand+=(--region "${region}")
  fi
  zone=$(yq eval '.cluster.zone // ""' "${testPlan}")
  if [ -n "${zone}" ]; then
      listClustersCommand+=(--zone "${zone}")
      deleteClusterCommand+=(--zone "${zone}")
  fi

  if "${listClustersCommand[@]}" | grep -q "${clusterName}"; then
    echo "${deleteClusterCommand[@]}"
    "${deleteClusterCommand[@]}"
  fi
}