FROM alpine:3.23@sha256:5b10f432ef3da1b8d4c7eb6c487f2f5a8f096bc91145e68878dd4a5019afde11

LABEL org.opencontainers.image.source=https://github.com/grafana/helm-chart-toolbox
LABEL org.opencontainers.image.description="Helm Chart Toolbox - Kubectl"
LABEL org.opencontainers.image.licenses=Apache-2.0

RUN apk add --no-cache bash coreutils curl gettext jq ca-certificates

# Download kubectl at various versions
ARG TARGETARCH
ARG KUBECTL_VERSIONS="1.29 1.30 1.31 1.32 1.33 1.34 1.35"
RUN set -eux; \
  for v in $KUBECTL_VERSIONS; do \
    echo "Downloading kubectl v${v}"; \
    curl -sSL -o "/usr/bin/kubectl-$v" "https://dl.k8s.io/release/$(curl -L -s "https://dl.k8s.io/release/stable-${v}.txt")/bin/linux/${TARGETARCH}/kubectl" && \
    chmod +x "/usr/bin/kubectl-$v"; \
  done
RUN ln -s /usr/bin/kubectl-1.35 /usr/bin/kubectl

ENTRYPOINT ["/usr/bin/kubectl"]
