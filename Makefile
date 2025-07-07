.PHONY: build
build: tools/helm-test/TestPlan.md
	make -C charts/query-test build

tools/helm-test/TestPlan.md: tools/helm-test/templates/test-plan.yaml
	docker run --rm --volume $(shell pwd):/src --workdir /src ghcr.io/grafana/hackathon-13-helm-chart-toolbox-doc-generator:0.1.0 --file $< > $@

.PHONY: lint
lint: lint-actions lint-shell lint-yaml

WORKFLOW_FILES = $(shell find .github/workflows -name "*.yml" -o -name "*.yaml")
.PHONY: lint-actions
lint-actions:
	@echo "Linting GitHub Action workflows..."
	@actionlint $(WORKFLOW_FILES)

SHELL_SCRIPTS = $(shell find . -name "*.sh")
.PHONY: lint-shell
lint-shell:
	@echo "Linting Shell scripts..."
	@shellcheck --rcfile=.shellcheckrc $(SHELL_SCRIPTS)

YAML_FILES = $(shell find . -name "*.yaml")
.PHONY: lint-yaml
lint-yaml:
	@echo "Linting YAML files..."
	@yamllint --strict --config-file .yamllint.yaml .
