
FROM bitnami/kubectl:1.29 AS kubectl-1-29
FROM bitnami/kubectl:1.30 AS kubectl-1-30
FROM bitnami/kubectl:1.31 AS kubectl-1-31
FROM bitnami/kubectl:1.32 AS kubectl-1-32
FROM bitnami/kubectl:1.33 AS kubectl-1-33

FROM ubuntu

LABEL org.opencontainers.image.source=https://github.com/grafana/helm-chart-toolbox
LABEL org.opencontainers.image.description="Helm Chart Toolbox - Kubernetes Objects Test"
LABEL org.opencontainers.image.licenses=Apache-2.0

RUN apt-get update && apt-get install -y gettext jq && rm -rf /var/lib/apt/lists/*
COPY --from=kubectl-1-29 /opt/bitnami/kubectl/bin/kubectl /usr/bin/kubectl-1.29
COPY --from=kubectl-1-30 /opt/bitnami/kubectl/bin/kubectl /usr/bin/kubectl-1.30
COPY --from=kubectl-1-31 /opt/bitnami/kubectl/bin/kubectl /usr/bin/kubectl-1.31
COPY --from=kubectl-1-32 /opt/bitnami/kubectl/bin/kubectl /usr/bin/kubectl-1.32
COPY --from=kubectl-1-33 /opt/bitnami/kubectl/bin/kubectl /usr/bin/kubectl-1.33
RUN ln -s /usr/bin/kubectl-1.33 /usr/bin/kubectl

COPY ["kubernetes-objects-test.sh", "/usr/bin/"]
