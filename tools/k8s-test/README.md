# k8s-test CLI

Self-contained CLI for running Helm chart tests using embedded manifests from `tools/helm-test/manifests`.

## Install

```bash
make build
install -m 0755 bin/k8s-test ~/bin/k8s-test
```

## Commands

```text
k8s-test                    # main command
k8s-test run                # full workflow (cluster -> deps -> subject -> tests)

k8s-test cluster info
k8s-test cluster check
k8s-test cluster create [--workers N]
k8s-test cluster delete

k8s-test deps list
k8s-test deps deploy

k8s-test subject info
k8s-test subject deploy
k8s-test subject upgrade
k8s-test subject delete

k8s-test test list
k8s-test test run [--phase deploy|upgrade|delete]
```

## Global flags

- `-d, --test-dir`: directory containing `test-plan.yaml` (default: current directory)

## Run options

- `--tidy`: delete the cluster after tests complete
- `--workers`: (kind only) number of worker nodes when creating a cluster if no configFile is provided (default: 1)

## Requirements

- Tools on PATH: `kubectl`, `helm`, `flux`, and a cluster provider (`kind` or `minikube`)

## Notes

- Manifests are embedded from `tools/helm-test/manifests/` at build time; rebuild to pick up changes.
- If `subject.type` is omitted in `test-plan.yaml`, it defaults to `helm`.


