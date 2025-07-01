VERSION = $(shell cat version)
IMAGE ?= "ghcr.io/grafana/hackathon-13-helm-chart-toolbox-doc-generator"
PLATFORMS ?= linux/amd64  # Only amd64 is supported

build: .temp/image-built-$(VERSION)
.temp/image-built-$(VERSION): Dockerfile generate.sh
	docker buildx build --platform $(PLATFORMS) --tag $(IMAGE):$(VERSION) .
	mkdir -p .temp && touch .temp/image-built-${VERSION}

push: .temp/image-built-$(VERSION)
	docker push $(IMAGE):$(VERSION)

.PHONY: clean
clean:
	rm -rf .temp
