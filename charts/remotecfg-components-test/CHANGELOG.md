# Changelog

## 0.1.0

- Initial version. Asserts that Grafana Alloy collectors are running the components Fleet Management holds for their cluster, read from each Alloy pod's `/api/v0/web/remotecfg/components` API and compared against expected sets supplied via `EXPECTED_<ROLE>` environment variables. (@TylerHelmuth)
