FROM ghcr.io/grafana/helm-chart-toolbox-kubectl:0.1.4@sha256:82225213d75a94eeabbdb85a5f1fdcef67018f7453982e24cd0179212f4ae886

LABEL org.opencontainers.image.source=https://github.com/grafana/helm-chart-toolbox
LABEL org.opencontainers.image.description="Helm Chart Toolbox - Kubernetes Objects Test"
LABEL org.opencontainers.image.licenses=Apache-2.0

COPY ["kubernetes-objects-test.sh", "/usr/bin/"]
