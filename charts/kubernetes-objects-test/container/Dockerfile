FROM alpine:3.22

LABEL org.opencontainers.image.source=https://github.com/grafana/helm-chart-toolbox
LABEL org.opencontainers.image.description="Helm Chart Toolbox - Kubernetes Objects Test"
LABEL org.opencontainers.image.licenses=Apache-2.0

RUN apk add --no-cache bash curl gettext jq ca-certificates

# Download kubectl at various versions
ARG KUBECTL_VERSIONS="1.29 1.30 1.31 1.32 1.33"
RUN set -eux; \
  for v in $KUBECTL_VERSIONS; do \
    curl -sSL -o /usr/bin/kubectl-$v "https://dl.k8s.io/release/$(curl -L -s "https://dl.k8s.io/release/stable-${v}.txt")/bin/linux/amd64/kubectl" && \
    chmod +x /usr/bin/kubectl-$v; \
  done; \
  ln -s /usr/bin/kubectl-1.33 /usr/bin/kubectl

COPY ["kubernetes-objects-test.sh", "/usr/bin/"]