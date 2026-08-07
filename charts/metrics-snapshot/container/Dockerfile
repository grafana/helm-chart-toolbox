FROM ubuntu:26.04@sha256:678c6550cc43645e08669028bc177f50be4e7c5b8cca677067b1914d4afc7a03

LABEL org.opencontainers.image.source=https://github.com/grafana/helm-chart-toolbox
LABEL org.opencontainers.image.description="Helm Chart Toolbox - Metrics Snapshot"
LABEL org.opencontainers.image.licenses=Apache-2.0

ARG YQ_VERSION=v4.53.3
ARG TARGETARCH

RUN apt-get update && \
    apt-get install --no-install-recommends -y ca-certificates curl gettext jq && \
    rm -rf /var/lib/apt/lists/*
RUN curl -sSL "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${TARGETARCH}" -o /usr/bin/yq && \
    chmod +x /usr/bin/yq

COPY ["*.sh", "/usr/bin/"]
