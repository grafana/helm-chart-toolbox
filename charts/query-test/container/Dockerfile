FROM grafana/pyroscope:1.18.0@sha256:e7edae4fd99dbb8695a1e03d7db96ab247630cf83842407908922b2f66aafc6a AS pyroscope
FROM ubuntu:24.04@sha256:cd1dba651b3080c3686ecf4e3c4220f026b521fb76978881737d24f200828b2b

LABEL org.opencontainers.image.source=https://github.com/grafana/helm-chart-toolbox
LABEL org.opencontainers.image.description="Helm Chart Toolbox - Query Test"
LABEL org.opencontainers.image.licenses=Apache-2.0

RUN apt-get update && \
    apt-get install --no-install-recommends -y bc ca-certificates curl gettext jq && \
    rm -rf /var/lib/apt/lists/*
COPY --from=pyroscope /usr/bin/profilecli /usr/bin/profilecli

COPY ["*.sh", "/usr/bin/"]
