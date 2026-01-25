FROM alpine/helm:4.1.0@sha256:905a068da43146a87a06c9c6f7f39cdb66a3cd0973dfc29607784f7172d8d171

LABEL org.opencontainers.image.source=https://github.com/grafana/helm-chart-toolbox
LABEL org.opencontainers.image.description="Helm Chart Toolbox - Schema Generator"
LABEL org.opencontainers.image.licenses=Apache-2.0

RUN helm plugin install --verify=false https://github.com/karuppiah7890/helm-schema-gen.git && \
    apk add --no-cache jq

COPY ["generate.sh", "/usr/bin/"]
ENTRYPOINT ["bash", "/usr/bin/generate.sh"]
