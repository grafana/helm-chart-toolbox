SHELL = /bin/bash
IMAGE ?= $(shell yq eval '.image.registry + "/" + .image.repository' values.yaml)
IMAGE_VERSION := $(shell yq eval '.appVersion' Chart.yaml)
PLATFORMS ?= linux/arm64,linux/amd64

.SECONDEXPANSION:
README.md: values.yaml Chart.yaml $$(wildcard README.md.gotmpl)
	docker run --rm --platform linux/amd64 --volume $(shell pwd):/chart ghcr.io/grafana/helm-chart-toolbox-doc-generator --chart /chart > $@

Chart.lock: Chart.yaml
	helm dependency update .
	@touch Chart.lock # Ensure the timestamp is updated

# Examples
EXAMPLE_VALUES_FILES := $(shell find docs/examples -name values.yaml)
EXAMPLE_OUTPUT_FILES := $(EXAMPLE_VALUES_FILES:values.yaml=output.yaml)
%/output.yaml: %/values.yaml Chart.yaml Chart.lock values.yaml values.schema.json
	helm template query-test . -f $< > $@

.PHONY: examples
examples: $(EXAMPLE_OUTPUT_FILES)

# Schemas
values.schema.json: values.yaml schema-mods/definitions/query.schema.json schema-mods/definitions/test.schema.json $$(wildcard schema-mods/*)
	docker run --rm --platform linux/amd64 --volume $(shell pwd):/chart ghcr.io/grafana/helm-chart-toolbox-schema-generator --chart /chart > $@

schema-mods/definitions/query.schema.json: definitions/query-values.yaml
	docker run --rm --platform linux/amd64 --volume $(shell pwd)/definitions:/definitions ghcr.io/grafana/helm-chart-toolbox-schema-generator --file /$< > $@

schema-mods/definitions/test.schema.json: definitions/test-values.yaml
	docker run --rm --platform linux/amd64 --volume $(shell pwd)/definitions:/definitions ghcr.io/grafana/helm-chart-toolbox-schema-generator --file /$< > $@

# Container image
build-image: .temp/image-built-$(IMAGE_VERSION)
.temp/image-built-$(IMAGE_VERSION): container/Dockerfile container/query-test.sh
	docker buildx build --platform $(PLATFORMS) --tag $(IMAGE):$(IMAGE_VERSION) container
	mkdir -p .temp && touch .temp/image-built-${IMAGE_VERSION}

push-image: .temp/image-built-$(IMAGE_VERSION)
	docker push $(IMAGE):$(IMAGE_VERSION)

.PHONY: clean
clean:
	rm -rf README.md values.schema.json .temp

.PHONY: build
build: README.md Chart.lock values.schema.json examples

.PHONY: test
test: build
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm lint .
	ct lint --lint-conf .lintconf.yaml --helm-dependency-extra-args=--skip-refresh --charts .
	docker run -t --rm --volume $(shell pwd):/apps helmunittest/helm-unittest:3.17.0-0.7.1 .
