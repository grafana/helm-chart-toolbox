# check

<!-- textlint-disable terminology -->
## Values

### Expectations

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| expect.count | int | `1` | Check that a certain number of matching objects have been returned. |

### Check

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| kind | string | `""` | The kind of the Kubernetes object to check for (e.g. Pod, Deployment, Service, etc...). |
| labels | object | `{}` | A label selector to filter the Kubernetes objects to check for. |
| name | string | `""` | The name of the Kubernetes object to check for. |
| namespace | string | `""` | The namespace of the Kubernetes object to check for. |
<!-- textlint-enable terminology -->
