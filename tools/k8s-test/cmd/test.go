package cmd

import (
	"fmt"

	"github.com/grafana/helm-chart-toolbox/tools/k8s-test/internal/plan"
	"github.com/grafana/helm-chart-toolbox/tools/k8s-test/internal/sh"
	"github.com/spf13/cobra"
)

var phase string

func newCmdTest() *cobra.Command {
	cmd := &cobra.Command{Use: "test", Short: "Test commands"}
	run := &cobra.Command{Use: "run", Short: "Run tests", RunE: testRun}
	run.Flags().StringVar(&phase, "phase", "", "Phase to run: deploy|upgrade|delete")
	cmd.AddCommand(&cobra.Command{Use: "list", Short: "List tests", RunE: testList})
	cmd.AddCommand(run)
	return cmd
}

func testList(cmd *cobra.Command, args []string) error {
	tp, err := plan.Load(testDir)
	if err != nil {
		return err
	}
	for _, t := range tp.Tests {
		fmt.Fprintln(cmd.OutOrStdout(), t.Type)
	}
	return nil
}

func testRun(cmd *cobra.Command, args []string) error {
	_ = phase // placeholder for future phase-specific logic
	tp, err := plan.Load(testDir)
	if err != nil {
		return err
	}
	for _, t := range tp.Tests {
		switch t.Type {
		case "delay":
			if err := sh.Run(cmd, "helm", "test", "delay", "--namespace", "toolbox", "--hide-notes", "--logs"); err != nil {
				return err
			}
		case "query-test":
			if err := sh.Run(cmd, "helm", "test", "query-test", "--namespace", "toolbox", "--hide-notes", "--logs"); err != nil {
				return err
			}
		case "kubernetes-objects-test":
			if err := sh.Run(cmd, "helm", "test", "kubernetes-objects-test", "--namespace", "toolbox", "--hide-notes", "--logs"); err != nil {
				return err
			}
		default:
			return fmt.Errorf("unknown test type: %s", t.Type)
		}
	}
	return nil
}
