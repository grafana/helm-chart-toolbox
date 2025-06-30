#!/usr/bin/env bash
CHART_DIR=$1

usage() {
  echo "USAGE: $0 <Chart Dir>"
  echo "Generates a JSON schema for the Helm chart values file."
  echo ""
  echo "  <Chart Dir> - The path to the Helm chart directory."
  echo ""
  echo "The following supplemental files are also supported and will be applied to the schema:"
  echo "  <Chart Dir>/schema-mods/*.jq - JQ commands to modify the schema."
  echo "  <Chart Dir>/schema-mods/*.json - JSON fields to overwrite in the default generated schema."
  echo "  <Chart Dir>/schema-mods/definitions/{name}.schema.json - Definitions to be added to the schema."
}

if [ -z "${CHART_DIR}" ]; then
  echo "Chart directory not defined!"
  usage
  exit 1
fi

if [ ! -d "${CHART_DIR}" ]; then
  echo "${CHART_DIR} is not a directory!"
  usage
  exit 1
fi

set -eo pipefail  # Exit immediately if a command fails.
shopt -s nullglob # Required when a chart does not use mod files.

helm schema-gen "${CHART_DIR}/values.yaml" > "${CHART_DIR}/values.schema.generated.json"

if [ -d "${CHART_DIR}/schema-mods" ]; then
  if [ -d "${CHART_DIR}/schema-mods/definitions" ]; then
    # Add definitions to the schema.
    for file in "${CHART_DIR}"/schema-mods/definitions/*.schema.json; do
      echo "Setting definition for ${file}..."
      name=$(basename "$file" .schema.json)
      jq --indent 4 \
        --arg name "${name}" \
        --slurpfile data "$file" \
        '.definitions[$name] = $data[0]' \
        "${CHART_DIR}/values.schema.generated.json" > "${CHART_DIR}/values.schema.modded.json"
      mv "${CHART_DIR}/values.schema.modded.json" "${CHART_DIR}/values.schema.generated.json"
    done
  fi

  # Applying JQ mods...
  for file in "${CHART_DIR}"/schema-mods/*.jq; do
    echo "Applying JQ mod for ${file}..."
    jq --indent 4 --from-file "$file" "${CHART_DIR}/values.schema.generated.json" > "${CHART_DIR}/values.schema.modded.json"
    mv "${CHART_DIR}/values.schema.modded.json" "${CHART_DIR}/values.schema.generated.json"
  done

  # Applying JSON mods...
  for file in "${CHART_DIR}"/schema-mods/*.json; do
    echo "Applying JSON mod for ${file}..."
    jq --indent 4 -s '.[0] * .[1]' "${CHART_DIR}/values.schema.generated.json" "$file" > "${CHART_DIR}/values.schema.modded.json"
    mv "${CHART_DIR}/values.schema.modded.json" "${CHART_DIR}/values.schema.generated.json"
  done
fi

mv "${CHART_DIR}/values.schema.generated.json" "${CHART_DIR}/values.schema.json"
echo "Done: ${CHART_DIR}/values.schema.json"
