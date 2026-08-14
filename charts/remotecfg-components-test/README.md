<!--
(NOTE: Do not edit README.md directly. It is a generated file!)
(      To make changes, please modify README.md.gotmpl and run `helm-docs`)
-->

# remotecfg-components-test

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.1.0](https://img.shields.io/badge/AppVersion-0.1.0-informational?style=flat-square)
A Helm Chart Toolbox test asserting that collectors run the Alloy components Fleet Management holds for their cluster, read from each Alloy pod's remotecfg components API.

## How it works

This chart asserts that Grafana Alloy collectors are running the components that Fleet Management holds for their
cluster. For each check it lists the collector's pods by label selector, queries each pod's
`/api/v0/web/remotecfg/components` API, and verifies that every one of those pods is running at least the expected set
of components for that collector `role`. The expected sets are supplied as `EXPECTED_<ROLE>` environment variables (the role, upper-cased) —
typically via `envFrom` a ConfigMap derived from Fleet Management.

## Usage

To use this chart, supply the expected component sets (via `envFrom`) and a list of per-collector checks:

```yaml
envFrom:
  - configMapRef:
      name: expected-components   # provides EXPECTED_DAEMONSET / EXPECTED_DEPLOYMENT
checks:
  - role: daemonset
    namespace: default
    selector: app.kubernetes.io/name=alloy,app.kubernetes.io/instance=grafana-cloud-alloy-daemonset
  - role: deployment
    namespace: default
    selector: app.kubernetes.io/name=alloy,app.kubernetes.io/instance=grafana-cloud-alloy-deployment
```

A check fails if any of the collector's pods is missing an expected component, if no pods match the selector, or if the
expected set for a role is empty (which means Fleet Management served nothing for that role). The test pod retries
`attempts` times with `delay` seconds between runs.

<!-- textlint-disable terminology -->
## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| petewall | <pete.wall@grafana.com> |  |
<!-- textlint-enable terminology -->
<!-- markdownlint-disable no-bare-urls -->
<!-- markdownlint-disable list-marker-space -->
## Source Code

* <https://github.com/grafana/helm-chart-toolbox/tree/main/charts/remotecfg-components-test>
<!-- markdownlint-enable list-marker-space -->
<!-- markdownlint-enable no-bare-urls -->

## Values

### Test settings

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| attempts | int | `10` | Number of times to retry the test on failure. |
| checks | list | `[]` | Per-collector checks: a list of `{ role, namespace, selector }`. `role` selects the expected component set from the `EXPECTED_<ROLE>` env var (see envFrom) and must be a valid env-var name segment (`[A-Za-z0-9_]`, no hyphens); `selector` is the label selector for that collector's Alloy pods. |
| delay | int | `30` | Delay, in seconds, between test runs. |
| envFrom | list | `[]` | Additional environment from existing ConfigMaps/Secrets — typically the expected-components ConfigMap carrying the `EXPECTED_<ROLE>` keys. |
| initialDelay | int | `0` | Initial delay, in seconds, before starting the first test run. |

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
| image.repository | string | `"grafana/helm-chart-toolbox-remotecfg-components-test"` | Test pod image repository. |
| image.tag | string | `""` | Test pod image tag. Default is the chart version. |

### Job settings

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| pod.extraAnnotations | object | `{}` | Extra annotations to add to the test runner pod. |
| pod.extraEnv | list | `[]` | Extra environment variables to add to the test runner pod. |
| pod.extraLabels | object | `{}` | Extra labels to add to the test runner pod. |
| pod.nodeSelector | object | `{"kubernetes.io/os":"linux"}` | nodeSelector to apply to the test runner pod. |
| pod.rbac | object | `{"create":true}` | RBAC settings for the service account. |
| pod.serviceAccount | object | `{"create":true,"name":""}` | Service Account to use for the test runner pod. |
| pod.tolerations | list | `[]` | Tolerations to apply to the test runner pod. |
