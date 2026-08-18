# check

<!-- textlint-disable terminology -->
## Values

### Check

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| namespace | string | `""` | The namespace of the collector's Alloy pods. |
| role | string | `""` | The name for the expected component set, matched to an `EXPECTED_<ROLE>` environment variable (the role, upper-cased) supplied via `envFrom`. Must be a valid environment-variable name segment (`[A-Za-z0-9_]`); avoid hyphens. |
| selector | string | `""` | A label selector identifying the collector's Alloy pods. |
<!-- textlint-enable terminology -->
