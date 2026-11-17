#!/usr/bin/env bash
set -euo pipefail

scriptDir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
deployScript="${DEPLOY_SUBJECT_SCRIPT:-${scriptDir}/deploy-subject}"

testRoot=$(mktemp -d "${TMPDIR:-/tmp}/helm-test-cleanup.XXXXXXXX")
realMktemp=$(command -v mktemp)
trap 'rm -rf -- "${testRoot}"' EXIT

mkdir -p "${testRoot}/bin" "${testRoot}/plan/chart"

export TOOLBOX_TEST_ROOT="${testRoot}"
export TOOLBOX_REAL_MKTEMP="${realMktemp}"
export TOOLBOX_HELM_CALLS_LOG="${testRoot}/helm-calls.log"
export TOOLBOX_VALUES_LOG="${testRoot}/values-files.log"

# Keep generated files inside the test's temporary directory.
cat > "${testRoot}/bin/mktemp" <<'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail
exec "${TOOLBOX_REAL_MKTEMP}" "${TOOLBOX_TEST_ROOT}/values.yaml.XXXXXX"
SCRIPT

# Check that each values file exists when Helm receives it.
cat > "${testRoot}/bin/helm" <<'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail

if [ "${1:-}" = "show" ]; then
  printf 'name: test-chart\n'
  exit 0
fi

if [ "${1:-}" != "upgrade" ]; then
  echo "Unexpected Helm command: ${1:-}" >&2
  exit 1
fi

printf 'call\n' >> "${TOOLBOX_HELM_CALLS_LOG}"

while [ "$#" -gt 0 ]; do
  if [ "$1" = "-f" ]; then
    test -s "${2:?Missing values file}"
    printf '%s\n' "$2" >> "${TOOLBOX_VALUES_LOG}"
    shift 2
  else
    shift
  fi
done

callNumber=$(wc -l < "${TOOLBOX_HELM_CALLS_LOG}")
if [ "${callNumber}" -eq "${TOOLBOX_HELM_FAIL_ON}" ]; then
  printf 'Simulated Helm failure on call %s\n' "${callNumber}" >&2
  exit 1
fi
SCRIPT

chmod +x "${testRoot}/bin/mktemp" "${testRoot}/bin/helm"

cat > "${testRoot}/plan/test-plan.yaml" <<'YAML'
kind: TestPlan
name: temp-values-regression

cluster:
  type: kind

subject:
  path: chart
  values:
    example: install
  upgrade:
    values:
      example: upgrade
YAML

run_case() {
  local label="$1"
  local failOn="$2"
  local expectedFiles="$3"
  local expectedCalls="$4"
  local testStatus=0
  local callCount
  local file
  local -a files=()

  : > "${TOOLBOX_HELM_CALLS_LOG}"
  : > "${TOOLBOX_VALUES_LOG}"

  PATH="${testRoot}/bin:${PATH}" TOOLBOX_HELM_FAIL_ON="${failOn}" \
    bash "${deployScript}" "${testRoot}/plan" \
    > "${testRoot}/run.log" 2>&1 || testStatus=$?

  if [ "${failOn}" -eq 0 ] && [ "${testStatus}" -ne 0 ]; then
    cat "${testRoot}/run.log"
    echo "FAIL: ${label} — unexpected failure"
    return 1
  fi

  if [ "${failOn}" -ne 0 ]; then
    if [ "${testStatus}" -eq 0 ] || \
      ! grep -Fq "Simulated Helm failure on call ${failOn}" "${testRoot}/run.log"; then
      cat "${testRoot}/run.log"
      echo "FAIL: ${label} — expected Helm failure was not observed"
      return 1
    fi
  fi

  callCount=$(wc -l < "${TOOLBOX_HELM_CALLS_LOG}")
  mapfile -t files < "${TOOLBOX_VALUES_LOG}"

  if [ "${callCount}" -ne "${expectedCalls}" ] || \
     [ "${#files[@]}" -ne "${expectedFiles}" ]; then
    cat "${testRoot}/run.log"
    echo "FAIL: ${label} — unexpected number of Helm calls or values files"
    return 1
  fi

  for file in "${files[@]}"; do
    if [ -e "${file}" ]; then
      echo "FAIL: ${label} — temporary file remains: ${file}"
      return 1
    fi
  done

  echo "PASS: ${label}"
}

run_case "successful install and upgrade" 0 2 2
run_case "install failure" 1 1 1
run_case "upgrade failure" 2 2 2

yq 'del(.subject.values) | del(.subject.upgrade.values) |
    .subject.upgrade.version = "1.0.0"' \
  "${testRoot}/plan/test-plan.yaml" > "${testRoot}/no-inline.yaml"
mv "${testRoot}/no-inline.yaml" "${testRoot}/plan/test-plan.yaml"

run_case "no inline values" 0 0 2
