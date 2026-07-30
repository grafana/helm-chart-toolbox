FROM alpine:3.24@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b

LABEL org.opencontainers.image.source=https://github.com/grafana/helm-chart-toolbox
LABEL org.opencontainers.image.description="Helm Chart Toolbox - Kubectl"
LABEL org.opencontainers.image.licenses=Apache-2.0

RUN apk add --no-cache bash coreutils curl gettext jq ca-certificates

# Download kubectl at various versions
ARG TARGETARCH
ARG KUBECTL_VERSIONS="1.29 1.30 1.31 1.32 1.33 1.34 1.35 1.36"
ARG KUBECTL_LATEST_VERSION="1.36"
RUN set -eux; \
  for v in $KUBECTL_VERSIONS; do \
    echo "Downloading kubectl v${v}"; \
    curl -sSL -o "/usr/bin/kubectl-$v" "https://dl.k8s.io/release/$(curl -L -s "https://dl.k8s.io/release/stable-${v}.txt")/bin/linux/${TARGETARCH}/kubectl" && \
    chmod +x "/usr/bin/kubectl-$v"; \
  done
RUN ln -s /usr/bin/kubectl-${KUBECTL_LATEST_VERSION} /usr/bin/kubectl

ENTRYPOINT ["/usr/bin/kubectl"]
