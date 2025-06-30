FROM grafana/pyroscope:1.14.0 AS pyroscope
FROM ubuntu

LABEL org.opencontainers.image.source=https://github.com/grafana/hackathon-13-helm-chart-toolbox
LABEL org.opencontainers.image.description="Helm Chart Toolbox - Query Test"
LABEL org.opencontainers.image.licenses=Apache-2.0

RUN apt-get update && apt-get install -y bc curl gettext jq && rm -rf /var/lib/apt/lists/*
COPY --from=pyroscope /usr/bin/profilecli /usr/bin/profilecli

COPY ["query-test.sh", "/usr/bin/"]
