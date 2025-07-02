
.PHONY: lint
lint: lint-shell lint-yaml

SHELL_SCRIPTS = $(shell find . -name "*.sh")
.PHONY: lint-shell
lint-shell:
	shellcheck --rcfile=.shellcheckrc $(SHELL_SCRIPTS)

YAML_FILES = $(shell find . -name "*.yaml")
.PHONY: lint-yaml
lint-yaml:
	yamllint --strict --config-file .yamllint.yaml .
