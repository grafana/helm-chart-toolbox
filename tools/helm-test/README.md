# Helm Test

## Running the test

Each test follows these steps:

1. Create the cluster
2. Deploy dependencies
3. Deploy Helm chart
4. Run tests
5. Delete the cluster (only if the `DELETE_CLUSTER` environment variable is set to `true`)

To run the test, simply run the following command:

```bash
helm-test
```

The test is re-entrant, so you can run it multiple times and completed steps will be skipped. This is useful for
debugging or iterating on your test without having to recreate the cluster or redeploy dependencies.

You can also run each step individually by using the following commands:

```bash
create-cluster
deploy-dependencies
deploy-subject
run-tests
delete-cluster
```

## Test Plans

The `test-plan.yaml` file defines the test plan for the Helm chart. It includes the following sections:

| Field          | Description                                                    | Required | Default |
|----------------|----------------------------------------------------------------|----------|---------|
| `name`         | The name of the test plan.                                     | Yes      |         |
| `subject`      | The Helm chart to be tested.                                   | Yes      |         |
| `cluster`      | The Kubernetes cluster to be created and used for testing.     | Yes      |         |
| `dependencies` | The dependencies to be deployed before testing the Helm chart. | No       | `[]`    |
| `tests`        | The tests to be run after the Helm chart has been deployed.    | No       | `[]`    |

### Subjects

| Field                 | Description                                              | Required | Default                   |
|-----------------------|----------------------------------------------------------|----------|---------------------------|
| `subject.releaseName` | The name of the Helm release to be created.              | No       | The name of the test plan |
| `subject.path`        | The path to the Helm chart directory or TGZ bundle.      | Yes      |                           |
| `subject.values`      | The values to be used for the Helm chart as inline YAML. | No       | `{}`                      |
| `subject.valuesFile`  | The path to a values file to be used for the Helm chart. | No       |                           |
| `subject.namespace`   | The namespace in which the Helm chart will be deployed.  | No       | `default`                 |

#### Post Install

Sometimes, you want to deploy additional resources after the Helm chart has been installed. For example, you may want to
instantiate a new custom resources that was defined by the Helm chart. You can do this by defining a `postInstall`
section in the `subject`.

| Field                       | Description                                                      | Required | Default |
|-----------------------------|------------------------------------------------------------------|----------|---------|
| `subject.postInstall.files` | A list of files to be applied after the Helm chart is installed. | No       | []      |

### Cluster

This section defines the Kubernetes cluster to be created and used for testing. It includes the following fields:

| Field          | Description                                                                        | Required | Default                        |
|----------------|------------------------------------------------------------------------------------|----------|--------------------------------|
| `cluster.type` | The type of Kubernetes cluster to be created. Supported types: `kind`, `minikube`. | Yes      |                                |
| `cluster.name` | The name of the new Kubernetes cluster.                                            | No       | `<test plan name>-test-cluster |

#### Kind

| Field                | Description                                                | Required | Default |
|----------------------|------------------------------------------------------------|----------|---------|
| `cluster.config`     | The Kind cluster configuration to be used, as inline YAML. | No       | `{}`    |
| `cluster.configFile` | The path to a Kind cluster configuration to be used.       | No       |         |

#### Minikube

No additional options are available. Notes that only one Minikube cluster can be created at a time.

### Dependencies

This section defines the dependencies to be deployed before testing the Helm chart. Its used for deploying backing
services, or other Helm charts that the chart under test depends on. It is an array of objects, each with the following
fields:

FluxCD is always deployed to the cluster, because this helps managing deploying the dependencies and tests in parallel.

| Field       | Description                                                                                          | Required | Default |
|-------------|------------------------------------------------------------------------------------------------------|----------|---------|
| `preset`    | A dependency preset to use. Supported presets: `grafana`, `prometheus`, `loki`, `tempo`, `pyroscope` | No       |         |
| `overrides` | When using a preset, apply this YAML as an override to the preset values.                            | No       | `{}`    |
| `directory` | The path to directory of Kubernetes manifest files to be applied.                                    | No       |         |
| `file`      | The path to a Kubernetes manifest file to be applied.                                                | No       |         |
| `manifest`  | A Kubernetes manifest file to be applied as inline YAML.                                             | No       |         |

### Tests

This section defines the tests to be run after the Helm chart has been deployed. It is an array of objects, each with
the following fields:

| Field    | Description                                                | Required | Default |
|----------|------------------------------------------------------------|----------|---------|
| `type`   | The type of test to be run. Supported types: `query-test`. | Yes      |         |
| `values` | The values to be used for the test as inline YAML.         | No       | `{}`    |
