#!/usr/bin/env bash

createMinikubeCluster() {
  command=(minikube start)
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
