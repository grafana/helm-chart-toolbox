SHELL = /bin/bash
IMAGE ?= $(shell yq eval '.image.registry + "/" + .image.repository' values.yaml)
IMAGE_VERSION := $(shell yq eval '.appVersion' Chart.yaml)
PLATFORMS ?= linux/arm64,linux/amd64

docs/check.md: check-values.yaml
	docker run --rm --volume $(shell pwd):/src --workdir /src ghcr.io/grafana/helm-chart-toolbox-doc-generator --file $< > $@

.SECONDEXPANSION:
README.md: values.yaml Chart.yaml $$(wildcard README.md.gotmpl)
	docker run --rm --platform linux/amd64 --volume $(shell pwd):/chart ghcr.io/grafana/helm-chart-toolbox-doc-generator --chart /chart > $@

Chart.lock: Chart.yaml
	helm dependency update .
	@touch Chart.lock # Ensure the timestamp is updated

values.schema.json: values.yaml $$(wildcard schema-mods/*)
	docker run --rm --platform linux/amd64 --volume $(shell pwd):/chart ghcr.io/grafana/helm-chart-toolbox-schema-generator --chart /chart > $@

build-image: .temp/image-built-$(IMAGE_VERSION)
.temp/image-built-$(IMAGE_VERSION): container/Dockerfile container/kubernetes-objects-test.sh
	docker buildx build --platform $(PLATFORMS) --tag $(IMAGE):$(IMAGE_VERSION) container
	mkdir -p .temp && touch .temp/image-built-${IMAGE_VERSION}

push-image: .temp/image-built-$(IMAGE_VERSION)
	docker push $(IMAGE):$(IMAGE_VERSION)

.PHONY: clean
clean:
	rm -rf README.md values.schema.json .temp

.PHONY: build
build: README.md docs/check.md Chart.lock values.schema.json

.PHONY: test
test: build
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm lint .
	ct lint --lint-conf .lintconf.yaml --helm-dependency-extra-args=--skip-refresh --charts .
	docker run -t --rm --volume $(shell pwd):/apps helmunittest/helm-unittest:3.17.0-0.7.1 .
