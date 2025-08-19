#!/usr/bin/env bash

function check_value {
  local actualValue=$1
  local expectedValue=$2
  local operator=$3

  echo "  Expected (${expectedValue}), Operator (${operator}), Actual (${actualValue})"

  case "${operator}" in
  "<")  operator="<" ;;
  "<=") operator="<=" ;;
  "=")  operator="==" ;;
  "==")  operator="==" ;;
  "!=") operator="!=" ;;
  ">=") operator=">=" ;;
  ">")  operator=">" ;;
  *)
    echo "  Unsupported operator: \"${operator}\""
    return 1
  esac
  local result

  if ! result=$(echo "${expectedValue} ${operator} ${actualValue}" | bc); then
    echo "  An error occurred while checking the result: ${result}"
    return 1
  fi
  if [ "${result}" -ne "1" ]; then
    echo "  Unexpected query result!"
    return 1
  fi
  return 0
}

function metrics_query {
  local query="${1}"
  local expectedCount="${2}"
  local expectedValue="${3}"
  local expectedOperator="${4}"

  if [ -z "${PROMETHEUS_URL}" ]; then
    echo "PROMETHEUS_URL is not defined. Unable to run PromQL queries!"
    return 1
  fi

  echo "Running PromQL query: ${PROMETHEUS_URL}?query=${query}..."
  if [ -z "${PROMETHEUS_TENANTID}" ]; then
    additionalRequestOptions=()
  else
    additionalRequestOptions=("-H" "X-Scope-OrgID: ${PROMETHEUS_TENANTID}")
  fi
  result=$(curl -skX POST "${additionalRequestOptions[@]}" -u "${PROMETHEUS_USER}:${PROMETHEUS_PASS}" "${PROMETHEUS_URL}" --data-urlencode "query=${query}")
  status=$(echo "${result}" | jq -r .status)
  if [ "${status}" != "success" ]; then
    echo "Query failed!"
    echo "Response: ${result}"
    return 1
  fi

  resultCount=$(echo "${result}" | jq '.data.result | length')
  if [ -n "${expectedCount}" ]; then
    echo "  Expected ${expectedCount} results. Found ${resultCount} results."
    if [ "${resultCount}" -ne "${expectedCount}" ]; then
      echo "  Unexpected number of results returned!"
      echo "Result: ${result}"
      return 1
    fi
  else
    if [ "${resultCount}" -eq 0 ]; then
      echo "Query returned no results"
      echo "Result: ${result}"
      return 1
    fi

    if [ -n "${expectedValue}" ]; then
      check_value "$(echo "${result}" | jq -r '.data.result[0].value[1] | tostring')" "${expectedValue}" "${expectedOperator}"
    fi
  fi
}

function logs_query {
  echo "Running LogQL query: ${LOKI_URL}?query=${1}..."
  result=$(curl -s --get -H "X-Scope-OrgID:${LOKI_TENANTID}" -u "${LOKI_USER}:${LOKI_PASS}" "${LOKI_URL}" --data-urlencode "query=${1}")
  status=$(echo "${result}" | jq -r .status)
  if [ "${status}" != "success" ]; then
    echo "Query failed!"
    echo "Response: ${result}"
    return 1
  fi

  resultCount=$(echo "${result}" | jq '.data.result | length')
  if [ "${resultCount}" -eq 0 ]; then
    echo "Query returned no results"
    echo "Result: ${result}"
    return 1
  fi
}

function traces_query {
  echo "Running TraceQL query: ${TEMPO_URL}?q=${1}..."
  result=$(curl -sk --get -u "${TEMPO_USER}:${TEMPO_PASS}" "${TEMPO_URL}" --data-urlencode "q=${1}")
  resultCount=$(echo "${result}" | jq '.traces | length')
  if [ "${resultCount}" -eq 0 ]; then
    echo "Query returned no results"
    echo "Result: ${result}"
    return 1
  fi
}

function profiles_query {
    echo "Running profiles query: ${1}..."
    result=$(profilecli query series --query="${1}")
    resultCount=$(echo "${result}" 2>/dev/null | jq --slurp 'length')
    if [ "${resultCount}" -eq 0 ]; then
      echo "Query returned no results"
      echo "Result: ${result}"
      return 1
    fi
}
