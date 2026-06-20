FROM grafana/pyroscope:2.1.0@sha256:73b23dbb99f154a0803c136abafdff825475f415dd4d4587538d014c672b5a55 AS pyroscope
FROM ubuntu:26.04@sha256:5e275723f82c67e387ba9e3c24baa0abdcb268917f276a0561c97bef9450d0b4

LABEL org.opencontainers.image.source=https://github.com/grafana/helm-chart-toolbox
LABEL org.opencontainers.image.description="Helm Chart Toolbox - Query Test"
LABEL org.opencontainers.image.licenses=Apache-2.0

RUN apt-get update && \
    apt-get install --no-install-recommends -y bc ca-certificates curl gettext jq && \
    rm -rf /var/lib/apt/lists/*
COPY --from=pyroscope /usr/bin/profilecli /usr/bin/profilecli

COPY ["*.sh", "/usr/bin/"]
