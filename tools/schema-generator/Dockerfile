FROM alpine/helm:4.0.1@sha256:4677d32ca3ed7181b100c2cb8a75faf4ed46f3a65933309084e8df204a5fa78e

LABEL org.opencontainers.image.source=https://github.com/grafana/helm-chart-toolbox
LABEL org.opencontainers.image.description="Helm Chart Toolbox - Schema Generator"
LABEL org.opencontainers.image.licenses=Apache-2.0

RUN helm plugin install https://github.com/karuppiah7890/helm-schema-gen.git && \
    apk add --no-cache jq

COPY ["generate.sh", "/usr/bin/"]
ENTRYPOINT ["bash", "/usr/bin/generate.sh"]
