package main

import (
	"fmt"
	"os"

	"github.com/grafana/helm-chart-toolbox/tools/k8s-test/cmd"
)

func main() {
	if err := cmd.Execute(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
