FROM ghcr.io/grafana/helm-chart-toolbox-kubectl:0.1.6@sha256:93766638612873629f97f26805391b46a4fe346dcfeb49b5ee881efe0b38d638

LABEL org.opencontainers.image.source=https://github.com/grafana/helm-chart-toolbox
LABEL org.opencontainers.image.description="Helm Chart Toolbox - Kubernetes Objects Test"
LABEL org.opencontainers.image.licenses=Apache-2.0

COPY ["kubernetes-objects-test.sh", "/usr/bin/"]
