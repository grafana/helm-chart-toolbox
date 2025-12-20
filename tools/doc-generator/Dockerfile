FROM jnorwood/helm-docs:v1.14.2@sha256:7e562b49ab6b1dbc50c3da8f2dd6ffa8a5c6bba327b1c6335cc15ce29267979c AS helm-docs
FROM alpine/helm:4.0.4@sha256:adb87b125214fd356ecc1a24a1e86e4afed0ee03de5d4391de4925777de7fd42

LABEL org.opencontainers.image.source=https://github.com/grafana/helm-chart-toolbox
LABEL org.opencontainers.image.description="Helm Chart Toolbox - Documentation Generator"
LABEL org.opencontainers.image.licenses=Apache-2.0

COPY --from=helm-docs /usr/bin/helm-docs /usr/bin/helm-docs

RUN apk add --no-cache jq

COPY ["generate.sh", "/usr/bin/"]
ENTRYPOINT ["bash", "/usr/bin/generate.sh"]
