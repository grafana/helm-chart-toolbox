VERSION = $(shell cat version)
IMAGE ?= "ghcr.io/grafana/helm-chart-toolbox-doc-generator"
PLATFORMS ?= linux/amd64  # Only amd64 is supported

##@ Container Image

.PHONY: build
build: .temp/image-built-$(VERSION)  ## Build the container image
.temp/image-built-$(VERSION): Dockerfile generate.sh
	docker buildx build --platform $(PLATFORMS) --tag $(IMAGE):$(VERSION) .
	mkdir -p .temp && touch .temp/image-built-${VERSION}

.PHONY: push
push: .temp/image-built-$(VERSION) ## Push the container image
	docker push $(IMAGE):$(VERSION)

push-latest: .temp/image-built-$(VERSION) ## Push the container image with 'latest' tag
	docker tag $(IMAGE):$(VERSION) $(IMAGE):latest
	docker push $(IMAGE):latest

.PHONY: clean
clean: ## Clean up generated files
	rm -rf .temp
	docker rmi $(IMAGE):$(VERSION)

##@ Test

TEST_INPUTS = $(wildcard tests/*/values.yaml)
TEST_OUTPUTS = $(TEST_INPUTS:tests/%/values.yaml=tests/%/actual.README.md)
TEST_TARGETS = $(TEST_INPUTS:tests/%/values.yaml=tests/%/run-test)
INVALID_YAML_FILE = $(shell pwd)/tests/invalid-yaml/values.yaml.invalid

.SECONDEXPANSION:
tests/%/actual.README.md: tests/%/values.yaml $$(wildcard tests/%/README.md.gotmpl) .temp/image-built-$(VERSION)
	docker run --rm --volume $(shell pwd)/$(shell dirname $<):/input --platform linux/amd64 $(IMAGE):$(VERSION) --file /input/values.yaml > $@

.SECONDEXPANSION:
tests/%/run-test: tests/%/actual.README.md $$(wildcard tests/%/expected.README.md)
	@if [ ! -f $(shell dirname $<)/expected.README.md ]; then cp $< $(shell dirname $<)/expected.README.md; fi

	diff $(shell dirname $<)/expected.README.md $<

.PHONY: test-invalid-yaml
test-invalid-yaml: .temp/image-built-$(VERSION)
	@! docker run --rm \
		--volume "$(INVALID_YAML_FILE):/input/values.yaml:ro" \
		--platform linux/amd64 \
		$(IMAGE):$(VERSION) \
		--file /input/values.yaml > /dev/null 2> .temp/invalid-yaml-file.log
	@grep -Fq "Failed to parse YAML file:" .temp/invalid-yaml-file.log
	@! docker run --rm \
		--volume "$(INVALID_YAML_FILE):/input/values.yaml:ro" \
		--platform linux/amd64 \
		$(IMAGE):$(VERSION) \
		--chart /input > /dev/null 2> .temp/invalid-yaml-chart.log
	@grep -Fq "Failed to parse YAML file:" .temp/invalid-yaml-chart.log
	@rm .temp/invalid-yaml-file.log .temp/invalid-yaml-chart.log

test: $(TEST_TARGETS) test-invalid-yaml ## Test schema generation

##@ General

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
