# test-plan.yaml

<!-- textlint-disable terminology -->
## Values

### General

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| apiVersion | string | `"helm-chart-toolbox.grafana.com/v1"` | The version of the test plan document. Do not change. |
| kind | string | `"TestPlan"` | The kind of the test plan document. Do not change. |
| name | string | `""` | The name of the test plan. |

### Cluster

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| cluster.config | string | `nil` | Configuration to use when creating the cluster as inline YAML. Supported for "kind" clusters only. |
| cluster.configFile | string | `nil` | Path to a configuration file to use when creating the cluster. Supported for "kind" clusters only. |
| cluster.type | string | `""` | The type of cluster to use for the test. Valid options are "kind" or "minikube" |

### Dependencies

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| dependencies | list | `[]` | The list of dependencies to be deployed before deploying the Helm chart test subject. There are a number of presets available, such as "prometheus", "loki", "tempo", "pyroscope", and "grafana". Each preset can have their default values overridden by specifying an `overrides` section with changes to its values. You can also specify a directory containing YAML files to apply, or a path to an individual manifest file. Finally, you can specify a manifest as inline YAML. |

### Subject

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| subject.name | string | `""` | The name of the Helm chart to use from the chart repository. |
| subject.namespace | string | `""` | The namespace to use when deploying the Helm chart. |
| subject.path | string | `""` | The path to the Helm chart or manifest file to test. |
| subject.postInstall.files | list | `[]` | The files to apply after the Helm chart is installed. |
| subject.releaseName | string | `""` | The release name to use when deploying the Helm chart. If not set, will use the test plan name. |
| subject.repository | string | `""` | The Helm chart repository to use. |
| subject.type | string | `"helm"` | The type of the test subject. The supported types are "helm", "manifest", and "terraform". |
| subject.upgrade.values | object | `{}` | The values to use when upgrading the Helm chart. |
| subject.upgrade.valuesFile | string | `""` | The path to a values file to use when upgrading the Helm chart. |
| subject.upgrade.version | optional | `""` | The version of the Helm chart to upgrade to from the chart repository. Special values are "latest" to use the lastest version of the chart. |
| subject.values | object | `{}` | The values to use when deploying the Helm chart. |
| subject.valuesFile | string | `""` | The path to a values file to use when deploying the Helm chart. |
| subject.version | optional | `""` | The version of the Helm chart to use from the chart repository. Special values are "latest", "previous-major", "previous-minor", and "previous-patch" to use the latest, previous major, previous minor, or previous patch version of the chart, respectively. |

### Tests

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| tests | list | `[]` | The list of test to be run after deploying the Helm chart test subject. Supported test types are: [query-test](https://github.com/grafana/helm-chart-toolbox/blob/main/charts/query-test) |
<!-- textlint-enable terminology -->
