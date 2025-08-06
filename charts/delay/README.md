<!--
(NOTE: Do not edit README.md directly. It is a generated file!)
(      To make changes, please modify README.md.gotmpl and run `helm-docs`)
-->

# delay

![Version: 0.1.1](https://img.shields.io/badge/Version-0.1.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.1.1](https://img.shields.io/badge/AppVersion-0.1.1-informational?style=flat-square)
A Helm Chart Toolbox "test" to simply delay. Useful for letting your system work for a certain amount of time before proceeding with the next test.

## How it works

This chart provides the ability to delay for a specified amount of time before running tests.
This can be useful for testing the readiness of services that may take some time to become available, or for allowing
time for routine processes to complete a few cycles before running tests.

## Usage

To use this chart, specify a delay:

```yaml
delay: 30  # Delay for 30 seconds
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

* <https://github.com/grafana/helm-chart-toolbox/tree/main/charts/delay>
<!-- markdownlint-enable list-marker-space -->
<!-- markdownlint-enable no-bare-urls -->

## Values

### Test settings

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| delay | int | `60` | The delay, in seconds. |

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
| image.registry | string | `"docker.io"` | Test pod image registry. |
| image.repository | string | `"library/busybox"` | Test pod image repository. |
| image.tag | string | `"latest"` | Test pod image tag. |

### Pod settings

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| pod.extraAnnotations | object | `{}` | Extra annotations to add to the test runner pods. |
| pod.extraLabels | object | `{}` | Extra labels to add to the test runner pods. |
| pod.serviceAccount | object | `{"name":""}` | Service Account to use for the test runner pods. |
| pod.tolerations | list | `[]` | Tolerations to apply to the test runner pods. |

### Job settings

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| pod.nodeSelector | object | `{"kubernetes.io/os":"linux"}` | nodeSelector to apply to the test runner pods. |
