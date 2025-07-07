#!/usr/bin/env bash

usage() {
  echo "USAGE: $0 [--chart <Chart Dir>] [--file values.yaml]"
  echo "Generates a JSON schema for the Helm chart values file."
  echo ""
  echo "  --chart <Chart Dir> - The path to the Helm chart directory."
  echo "  --file  <Values File> - The path to a YAML file."
  echo ""
  echo "The following supplemental files are also supported and will be applied to the schema:"
  echo "  <Chart Dir>/schema-mods/*.jq - JQ commands to modify the schema."
  echo "  <Chart Dir>/schema-mods/*.json - JSON fields to overwrite in the default generated schema."
  echo "  <Chart Dir>/schema-mods/definitions/{name}.schema.json - Definitions to be added to the schema."
}

CHART_DIR=""
VALUES_FILE=""
while [ $# -gt 0 ]; do
  case "$1" in
    -c|-chart|--chart)
      CHART_DIR="$2"
      shift
    ;;
    -f|-file|--file)
      VALUES_FILE="$2"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unexpected argument: $1" 1>&2
      usage
      exit 1
  esac
  shift
done

if [ -z "${CHART_DIR}" ] && [ -z "${VALUES_FILE}" ]; then
  echo "Either --chart or --file option must be provided." 1>&2
  usage
  exit 1
fi

if [ -n "${CHART_DIR}" ] && [ -n "${VALUES_FILE}" ]; then
  echo "Both --chart and --file options are mutually exclusive. Please provide only one." 1>&2
  usage
  exit 1
fi

if [ -n "${VALUES_FILE}" ]; then
  echo "Generating schema based on file: ${VALUES_FILE}" 1>&2
  if [ ! -f "${VALUES_FILE}" ]; then
    echo "${VALUES_FILE} is not a file!" 1>&2
    usage
    exit 1
  fi

  CHART_DIR="/tmp/temp-chart"
  helm create "${CHART_DIR}" > /dev/null
  cp "${VALUES_FILE}" "${CHART_DIR}/values.yaml"
  if [ -d "$(dirname "${VALUES_FILE}")/schema-mods" ]; then
    cp -rf "$(dirname "${VALUES_FILE}")/schema-mods" "${CHART_DIR}/schema-mods"
  fi
else
  echo "Generating schema based on Helm chart: ${CHART_DIR}" 1>&2
fi

if [ ! -d "${CHART_DIR}" ]; then
  echo "${CHART_DIR} is not a directory!" 1>&2
  usage
  exit 1
fi

set -eo pipefail  # Exit immediately if a command fails.
shopt -s nullglob # Required when a chart does not use mod files.

helm schema-gen "${CHART_DIR}/values.yaml" > /tmp/values.schema.generated.json

if [ -d "${CHART_DIR}/schema-mods" ]; then
  if [ -d "${CHART_DIR}/schema-mods/definitions" ]; then
    # Add definitions to the schema.
    for file in "${CHART_DIR}"/schema-mods/definitions/*.schema.json; do
      name=$(basename "$file" .schema.json)
      echo "Setting $name definition for ${file}..." 1>&2
      jq --indent 4 --arg name "${name}" 'del(.["$schema"])' "${file}" > "/tmp/${name}.tmp"
      jq --indent 4 \
        --arg name "${name}" \
        --slurpfile data "/tmp/${name}.tmp" \
        '.definitions[$name] = $data[0]' \
        /tmp/values.schema.generated.json > /tmp/values.schema.modded.json
      mv /tmp/values.schema.modded.json /tmp/values.schema.generated.json
    done
  fi

  # Applying JQ mods...
  for file in "${CHART_DIR}"/schema-mods/*.jq; do
    echo "Applying JQ mod for ${file}..." 1>&2
    jq --indent 4 --from-file "$file" /tmp/values.schema.generated.json > /tmp/values.schema.modded.json
    mv /tmp/values.schema.modded.json /tmp/values.schema.generated.json
  done

  # Applying JSON mods...
  for file in "${CHART_DIR}"/schema-mods/*.json; do
    echo "Applying JSON mod for ${file}..." 1>&2
    jq --indent 4 -s '.[0] * .[1]' /tmp/values.schema.generated.json "$file" > /tmp/values.schema.modded.json
    mv /tmp/values.schema.modded.json /tmp/values.schema.generated.json
  done
fi

cat /tmp/values.schema.generated.json
