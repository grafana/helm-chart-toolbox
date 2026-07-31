# Changelog

## 0.1.0

* Initial version of the metrics-snapshot test. Runs a PromQL query, records the
  metric names and their series counts as a snapshot, and compares subsequent runs
  against a saved baseline, reporting added, missing, and changed metrics.
