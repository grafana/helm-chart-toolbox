FROM grafana/pyroscope:1.19.0@sha256:6e8084763afe8e362ff16342b5c019dfa00c6ca6e85ba2dce81af38b4c6afbb2 AS pyroscope
FROM ubuntu:24.04@sha256:c4a8d5503dfb2a3eb8ab5f807da5bc69a85730fb49b5cfca2330194ebcc41c7b

LABEL org.opencontainers.image.source=https://github.com/grafana/helm-chart-toolbox
LABEL org.opencontainers.image.description="Helm Chart Toolbox - Query Test"
LABEL org.opencontainers.image.licenses=Apache-2.0

RUN apt-get update && \
    apt-get install --no-install-recommends -y bc ca-certificates curl gettext jq && \
    rm -rf /var/lib/apt/lists/*
COPY --from=pyroscope /usr/bin/profilecli /usr/bin/profilecli

COPY ["*.sh", "/usr/bin/"]
