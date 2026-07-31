<!--
(NOTE: Do not edit README.md directly. It is a generated file!)
(      To make changes, please modify README.md.gotmpl and run `helm-docs`)
-->

# metrics-snapshot

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.1.0](https://img.shields.io/badge/AppVersion-0.1.0-informational?style=flat-square)
A Helm Chart Toolbox test that snapshots the metrics returned by a PromQL query and compares them against a saved baseline.

## How it works

This chart runs a PromQL query against Prometheus and records the set of metric names it
returns, along with the number of series for each one (its cardinality). The result is a
snapshot that can be saved to a file and used as a baseline for future runs.

Two steps run as Helm test hooks:

1. **generate** (always runs first): runs the query and prints a YAML snapshot of the
   metric names and their series counts. Save this output as your baseline file.
2. **compare** (runs only when a baseline is provided): runs the query again and compares
   the current metrics against the baseline, reporting metrics that were added or removed,
   and metrics whose series count changed by more than the reporting threshold. The test
   fails when a change exceeds the failing threshold, or (by default) when metrics are
   added or removed.

When used with the [helm-test](https://github.com/grafana/helm-chart-toolbox/tree/main/tools/helm-test)
tool, set a `dataFile` on the test. If the file exists next to the `test-plan.yaml`, it is
injected as the baseline; if it does not exist yet (a first run), only the generate step
runs so you can capture the output and commit it as the baseline.

## Usage

```yaml
query: '{__name__=~".+", job="my-app"}'
reportThreshold: 1
failThreshold: 20
env:
  PROMETHEUS_URL: https://prometheus-server.prometheus.svc:9090/api/v1/query
  PROMETHEUS_USER: promuser
  PROMETHEUS_PASS: prometheuspassword
```

In a test plan:

```yaml
tests:
  - type: metrics-snapshot
    dataFile: metrics-snapshot.yaml
    values:
      query: '{__name__=~".+", job="my-app"}'
      env:
        PROMETHEUS_URL: http://prometheus-server.prometheus.svc:9090/api/v1/query
```

<!-- textlint-disable terminology -->
## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| petewall | <pete.wall@grafana.com> |  |
<!-- textlint-enable terminology -->
<!-- markdownlint-disable no-bare-urls -->
<!-- markdownlint-disable list-marker-space -->
## Source Code

* <https://github.com/grafana/helm-chart-toolbox/tree/main/charts/metrics-snapshot>
<!-- markdownlint-enable list-marker-space -->
<!-- markdownlint-enable no-bare-urls -->

## Values

### Test settings

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| attempts | int | `10` | Number of times to retry the test on a transient (query) failure. |
| delay | int | `30` | Delay, in seconds, between test runs. |
| initialDelay | int | `0` | Initial delay, in seconds, before starting the first test run. |

### Environment Variables

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| env | object | `{}` | Environment variables used to connect to Prometheus. Stored in a Secret. |
| envFrom | list | `[]` | Add additional environment variables from configmaps or secrets. |

### Comparison settings

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| failOnMissingMetrics | bool | `true` | Fail the comparison when metrics in the baseline are no longer present. |
| failOnNewMetrics | bool | `true` | Fail the comparison when metrics appear that were not in the baseline. |
| failThreshold | int | `20` | The percentage change in a metric's series count (or the total series count) above which the comparison fails the test. |
| previousData | string | `""` | The baseline snapshot to compare against, as a YAML string. This is normally injected by the helm-test tool from the `dataFile` next to the test plan. When empty, only the generate step runs (which prints a snapshot to seed the baseline). |
| reportThreshold | int | `1` | The percentage change in a metric's series count (or the total series count) above which the difference is reported. |

### General settings

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| fullnameOverride | string | `""` | Full name override |
| nameOverride | string | `""` | Name override |

### Image Registry

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.image.pullSecrets | list | `[]` | Optional set of global image pull secrets. |
| global.image.registry | string | `""` | Global image registry to use if it needs to be overridden for some specific use cases (e.g local registries, custom images, ...) |

### Image settings

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| image.pullSecrets | list | `[]` | Optional set of image pull secrets. |
| image.registry | string | `"ghcr.io"` | Test pod image registry. |
| image.repository | string | `"grafana/helm-chart-toolbox-metrics-snapshot"` | Test pod image repository. |
| image.tag | string | `""` | Test pod image tag. Default is the chart version. |

### Job settings

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| pod.extraAnnotations | object | `{}` | Extra annotations to add to the test runner pods. |
| pod.extraLabels | object | `{}` | Extra labels to add to the test runner pods. |
| pod.nodeSelector | object | `{"kubernetes.io/os":"linux"}` | nodeSelector to apply to the test runner pods. |
| pod.serviceAccount | object | `{"name":""}` | Service Account to use for the test runner pods. |
| pod.tolerations | list | `[]` | Tolerations to apply to the test runner pods. |

### Query settings

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| query | string | `""` | The PromQL query to run. Its result set is grouped by metric name to produce the snapshot. Environment variables in the query are substituted at runtime. |
