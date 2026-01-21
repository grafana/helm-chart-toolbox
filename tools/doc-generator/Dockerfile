FROM --platform=$BUILDPLATFORM jnorwood/helm-docs:v1.14.2@sha256:7e562b49ab6b1dbc50c3da8f2dd6ffa8a5c6bba327b1c6335cc15ce29267979c AS helm-docs
FROM --platform=$BUILDPLATFORM alpine/helm:4.0.5@sha256:68d4c1fbe831786d6a74ad8efee3655a0ab3d03919cb2f4911e3e391e941c0b5

LABEL org.opencontainers.image.source=https://github.com/grafana/helm-chart-toolbox
LABEL org.opencontainers.image.description="Helm Chart Toolbox - Documentation Generator"
LABEL org.opencontainers.image.licenses=Apache-2.0

COPY --from=helm-docs /usr/bin/helm-docs /usr/bin/helm-docs

RUN apk add --no-cache jq

COPY ["generate.sh", "/usr/bin/"]
ENTRYPOINT ["bash", "/usr/bin/generate.sh"]
