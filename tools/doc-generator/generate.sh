#!/usr/bin/env bash

usage() {
  echo "USAGE: $0 [--chart <Chart Dir>] [--file values.yaml [--template <Go Template File>]]"
  echo "Generates a README from a Helm chart values file."
  echo ""
  echo "  --chart    <Chart Dir>        - The path to the Helm chart directory."
  echo "  --file     <Values File>      - The path to a YAML file."
  echo "  --template <Go Template File> - The path to a gotmpl file."
}

CHART_DIR=""
VALUES_FILE=""
TEMPLATE_FILE=""
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
    -t|-template|--template)
      TEMPLATE_FILE="$2"
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
  echo "Generating README based on file: ${VALUES_FILE}" 1>&2
  if [ ! -f "${VALUES_FILE}" ]; then
    echo "${VALUES_FILE} is not a file!" 1>&2
    usage
    exit 1
  fi

  CHART_DIR="/tmp/temp-chart"
  helm create "${CHART_DIR}" > /dev/null
  cp "${VALUES_FILE}" "${CHART_DIR}/values.yaml"
  if [ -f "${TEMPLATE_FILE}" ]; then
    echo "Using template file: ${TEMPLATE_FILE}" 1>&2
    cp "${TEMPLATE_FILE}" "${CHART_DIR}/README.md.gotmpl"
  else
    {
      echo "# $(basename -s -values.yaml "${VALUES_FILE}")"
      echo ""
      echo '<!-- textlint-disable terminology -->'
      echo '{{ template "chart.valuesSection" . }}'
      echo '<!-- textlint-enable terminology -->'
    } > ${CHART_DIR}/README.md.gotmpl
  fi
else
  echo "Generating README based on Helm chart: ${CHART_DIR}" 1>&2
fi

if [ ! -d "${CHART_DIR}" ]; then
  echo "${CHART_DIR} is not a directory!" 1>&2
  usage
  exit 1
fi

set -eo pipefail  # Exit immediately if a command fails.
shopt -s nullglob # Required when a chart does not use mod files.

cd "${CHART_DIR}"
helm-docs --chart-to-generate . --output-file README.md.generated

cat "${CHART_DIR}/README.md.generated"
rm "${CHART_DIR}/README.md.generated"

