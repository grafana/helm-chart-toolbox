# Changelog

## 0.2.0

* Add `previousDataConfigMap` to reference an existing ConfigMap as the baseline source,
  instead of only supporting an inline `previousData` string. This pairs with the
  helm-test `configmap` dependency for storing larger baselines.

## 0.1.0

* Initial version of the metrics-snapshot test. Runs a PromQL query, records the
  metric names and their series counts as a snapshot, and compares subsequent runs
  against a saved baseline, reporting added, missing, and changed metrics.
