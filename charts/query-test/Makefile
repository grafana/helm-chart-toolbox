VERSION = $(shell yq eval '.version' Chart.yaml)
HAS_HELM_DOCS := $(shell command -v helm-docs;)
HAS_HELM_UNITTEST := $(shell helm plugin list | grep unittest 2> /dev/null)
IMAGE ?= $(shell yq eval '.image.registry + "/" + .image.repository' values.yaml)
PLATFORMS ?= linux/arm64,linux/amd64

.SECONDEXPANSION:
README.md: values.yaml Chart.yaml $$(wildcard README.md.gotmpl)
ifdef HAS_HELM_DOCS
	helm-docs
else
	docker run --rm --volume "$(shell pwd):/helm-docs" -u $(shell id -u) jnorwood/helm-docs:latest
endif

Chart.lock: Chart.yaml
	helm dependency update .
	@touch Chart.lock # Ensure the timestamp is updated

values.schema.json: values.yaml $$(wildcard schema-mods/*)
	docker run -it --rm --volume $(shell pwd):/chart ghcr.io/grafana/hackathon-13-helm-chart-toolbox-schema-generator:0.1.0 /chart

build-image: .temp/image-built-$(VERSION)
.temp/image-built-$(VERSION): container/Dockerfile container/query-test.sh
	docker buildx build --platform $(PLATFORMS) --tag $(IMAGE):$(VERSION) container
	mkdir -p .temp && touch .temp/image-built-${VERSION}

push-image: .temp/image-built-$(VERSION)
	docker push $(IMAGE):$(VERSION)

.PHONY: clean
clean:
	rm -rf README.md values.schema.json .temp

.PHONY: build
build: README.md Chart.lock values.schema.json

.PHONY: test
test: build
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm lint .
	ct lint --lint-conf .lintconf.yaml --helm-dependency-extra-args=--skip-refresh --charts .
ifdef HAS_HELM_UNITTEST
	helm unittest .
else
	docker run --rm --volume $(shell pwd):/apps helmunittest/helm-unittest:3.17.0-0.7.1 .
endif
