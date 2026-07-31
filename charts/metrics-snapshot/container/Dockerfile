FROM ubuntu:26.04@sha256:5e275723f82c67e387ba9e3c24baa0abdcb268917f276a0561c97bef9450d0b4

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
