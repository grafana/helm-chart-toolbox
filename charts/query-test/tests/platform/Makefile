QUERY_TEST_SCRIPT=../../container/query-test.sh

test: test-metrics test-logs

test-metrics: metrics-queries.json
	$(QUERY_TEST_SCRIPT) $<

test-logs: logs-queries.json
	$(QUERY_TEST_SCRIPT) $<
