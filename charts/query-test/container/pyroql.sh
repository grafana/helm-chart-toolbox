#!/bin/bash

scriptDir=$(dirname "$(readlink -f "$0")")
source "${scriptDir}/common.sh"

usage() {
  echo "USAGE: pyroql.sh <query>"
  echo "Run a profiles query against Pyroscope"
  echo
  echo "Required environment variables:"
  echo "  PROFILECLI_URL - The URL for your Pyroscope service (e.g. localhost:4040)"
  echo "  PROFILECLI_USERNAME - The username for running Pyroscope queries"
  echo "  PROFILECLI_PASSWORD - The password for running Pyroscope queries"
}

if [ -z "${1}" ] || [ "${1}" == "-h" ]; then
  usage
  exit 0
fi

profiles_query "${1}"
