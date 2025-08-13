VERSION = $(shell cat version)
IMAGE ?= "ghcr.io/grafana/helm-chart-toolbox-kubectl"
PLATFORMS ?= linux/arm64,linux/amd64

##@ Container Image

.PHONY: build
build: .temp/image-built-$(VERSION)  ## Build the container image
.temp/image-built-$(VERSION): Dockerfile
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

##@ General

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
