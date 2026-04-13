APP := k8s-test
ROOT := $(shell git rev-parse --show-toplevel)
SRC_MANIFESTS := $(ROOT)/tools/helm-test/manifests
EMBED_DIR := internal/helmtestfs/manifests

.PHONY: embed-manifests
embed-manifests: ## Copy tools/helm-test/manifests into embedded tree
	rm -rf $(EMBED_DIR)
	mkdir -p $(EMBED_DIR)
	cp -R $(SRC_MANIFESTS)/* $(EMBED_DIR)/

.PHONY: build
build: embed-manifests ## Build the CLI with embedded manifests
	GO111MODULE=on CGO_ENABLED=0 go build -ldflags='-s -w' -o bin/$(APP) ./

.PHONY: clean
clean:
	rm -rf bin $(EMBED_DIR)

.PHONY: help
help:
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)


