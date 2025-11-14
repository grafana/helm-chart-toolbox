FROM ghcr.io/grafana/helm-chart-toolbox-kubectl:0.1.2@sha256:c7adcc4db378d73fbc1d6a83b3ca2d7a6dcab40c4a54a8246da01d3235569083

LABEL org.opencontainers.image.source=https://github.com/grafana/helm-chart-toolbox
LABEL org.opencontainers.image.description="Helm Chart Toolbox - Kubernetes Objects Test"
LABEL org.opencontainers.image.licenses=Apache-2.0

COPY ["kubernetes-objects-test.sh", "/usr/bin/"]
