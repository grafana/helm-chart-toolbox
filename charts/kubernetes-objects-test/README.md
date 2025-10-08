<!--
(NOTE: Do not edit README.md directly. It is a generated file!)
(      To make changes, please modify README.md.gotmpl and run `helm-docs`)
-->

# kubernetes-objects-test

![Version: 0.2.0](https://img.shields.io/badge/Version-0.2.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.2.0](https://img.shields.io/badge/AppVersion-0.2.0-informational?style=flat-square)
A Helm Chart Toolbox test for asserting that kubernetes objects are created as expected.

## How it works

This chart provides a means for encoding checks for Kubernetes Objects. This can be used to verify that certain objects
exist in a Kubernetes cluster.

## Usage

To use this chart, specify a test:

```yaml
checks:
  - kind: node
    expect:
      count: 2
  - kind: deployment
    name: grafana
    namespace: grafana
```

Each check runs sequentially, and the test fails if any of the checks return an error or fails an expectation.

<!-- textlint-disable terminology -->
## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| petewall | <pete.wall@grafana.com> |  |
<!-- textlint-enable terminology -->
<!-- markdownlint-disable no-bare-urls -->
<!-- markdownlint-disable list-marker-space -->
## Source Code

* <https://github.com/grafana/helm-chart-toolbox/tree/main/charts/kubernetes-objects-test>
<!-- markdownlint-enable list-marker-space -->
<!-- markdownlint-enable no-bare-urls -->

## Values

### Test settings

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| attempts | int | `10` | Number of times to retry the test on failure. |
| checks | list | `[]` | The checks to run. |
| delay | int | `30` | Delay, in seconds, between test runs. |
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
| image.repository | string | `"grafana/helm-chart-toolbox-kubernetes-objects-test"` | Test pod image repository. |
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
