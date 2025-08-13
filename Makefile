.PHONY: build
build: tools/helm-test/TestPlan.md
	make -C charts/query-test build
	make -C charts/kubernetes-objects-test build

tools/helm-test/TestPlan.md: tools/helm-test/manifests/templates/test-plan.yaml
	docker run --rm --volume $(shell pwd):/src --workdir /src ghcr.io/grafana/helm-chart-toolbox-doc-generator --file $< > $@

##@ Test

.PHONY: lint
lint: lint-actions lint-dockerfile lint-shell lint-yaml lint-zizmor ## Run all linters

WORKFLOW_FILES = $(shell find .github/workflows -name "*.yml" -o -name "*.yaml")
.PHONY: lint-actions
lint-actions: ## Lint GitHub Action workflows
	@echo "Linting GitHub Action workflows..."
	@actionlint $(WORKFLOW_FILES)

DOCKERFILES = $(shell find . -name "Dockerfile")
.PHONY: lint-dockerfile
lint-dockerfile: ## Lint Dockerfiles
	@echo "Linting Dockerfiles..."
	@for df in $(DOCKERFILES); do \
  		echo "  $$df"; \
		docker run --rm -i -v $(shell pwd)/.hadolint.yaml:/.hadolint.yaml hadolint/hadolint < "$$df" || exit 1; \
	done

SHELL_SCRIPTS = $(shell find . -name "*.sh")
.PHONY: lint-shell
lint-shell: ## Lint Shell scripts
	@echo "Linting Shell scripts..."
	@shellcheck $(SHELL_SCRIPTS)

YAML_FILES = $(shell find . -name "*.yaml")
.PHONY: lint-yaml
lint-yaml: ## Lint YAML files
	@echo "Linting YAML files..."
	@yamllint --strict --config-file .yamllint.yaml .

.PHONY: lint-zizmor
lint-zizmor: ## Statically analyze GitHub Action workflows
	@echo "Running Zizmor..."
	@docker run --rm --volume $(shell pwd):/src ghcr.io/woodruffw/zizmor@sha256:ebb58dabdf1cd44db1c260a81b555e94ea6dba798cd1bfde378cbfed8f493dde /src  # v1.6.0

##@ General

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
