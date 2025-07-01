FROM jnorwood/helm-docs:v1.14.2 AS helm-docs
FROM alpine/helm:3.15.4

LABEL org.opencontainers.image.source=https://github.com/grafana/hackathon-13-helm-chart-toolbox
LABEL org.opencontainers.image.description="Helm Chart Toolbox - Documentation Generator"
LABEL org.opencontainers.image.licenses=Apache-2.0

COPY --from=helm-docs /usr/bin/helm-docs /usr/bin/helm-docs

RUN apk add --no-cache jq

COPY ["generate.sh", "/usr/bin/"]
ENTRYPOINT ["bash", "/usr/bin/generate.sh"]
