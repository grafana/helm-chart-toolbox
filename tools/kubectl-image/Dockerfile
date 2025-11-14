FROM alpine:3.22@sha256:4b7ce07002c69e8f3d704a9c5d6fd3053be500b7f1c69fc0d80990c2ad8dd412

LABEL org.opencontainers.image.source=https://github.com/grafana/helm-chart-toolbox
LABEL org.opencontainers.image.description="Helm Chart Toolbox - Kubectl"
LABEL org.opencontainers.image.licenses=Apache-2.0

RUN apk add --no-cache bash curl gettext jq ca-certificates

# Download kubectl at various versions
ARG TARGETARCH
ARG KUBECTL_VERSIONS="1.29 1.30 1.31 1.32 1.33 1.34"
RUN set -eux; \
  for v in $KUBECTL_VERSIONS; do \
    echo "Downloading kubectl v${v}"; \
    curl -sSL -o "/usr/bin/kubectl-$v" "https://dl.k8s.io/release/$(curl -L -s "https://dl.k8s.io/release/stable-${v}.txt")/bin/linux/${TARGETARCH}/kubectl" && \
    chmod +x "/usr/bin/kubectl-$v"; \
  done
RUN ln -s /usr/bin/kubectl-1.34 /usr/bin/kubectl

ENTRYPOINT ["/usr/bin/kubectl"]
