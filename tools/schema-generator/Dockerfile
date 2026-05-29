FROM alpine/helm:4.1.4@sha256:8edcaedab4d9864886b7f443d55731be87d4b5ec7dca714c24551455707a8aac

LABEL org.opencontainers.image.source=https://github.com/grafana/helm-chart-toolbox
LABEL org.opencontainers.image.description="Helm Chart Toolbox - Schema Generator"
LABEL org.opencontainers.image.licenses=Apache-2.0

RUN helm plugin install --verify=false https://github.com/karuppiah7890/helm-schema-gen.git && \
    apk add --no-cache jq

COPY ["generate.sh", "/usr/bin/"]
ENTRYPOINT ["bash", "/usr/bin/generate.sh"]
