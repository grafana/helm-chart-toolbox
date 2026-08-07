FROM grafana/pyroscope:2.2.0@sha256:7f019d866e474609c7f112d2632d75bdf8ad418c08461fcb5193444bb6dc476d AS pyroscope
FROM ubuntu:26.04@sha256:678c6550cc43645e08669028bc177f50be4e7c5b8cca677067b1914d4afc7a03

LABEL org.opencontainers.image.source=https://github.com/grafana/helm-chart-toolbox
LABEL org.opencontainers.image.description="Helm Chart Toolbox - Query Test"
LABEL org.opencontainers.image.licenses=Apache-2.0

RUN apt-get update && \
    apt-get install --no-install-recommends -y bc ca-certificates curl gettext jq && \
    rm -rf /var/lib/apt/lists/*
COPY --from=pyroscope /usr/bin/profilecli /usr/bin/profilecli

COPY ["*.sh", "/usr/bin/"]
