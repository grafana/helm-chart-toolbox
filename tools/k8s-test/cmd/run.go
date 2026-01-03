package cmd

import (
	"github.com/grafana/helm-chart-toolbox/tools/k8s-test/internal/plan"
	"github.com/spf13/cobra"
)

var tidy bool
var workers int

func newCmdRun() *cobra.Command {
	cmd := &cobra.Command{Use: "run", Short: "Run full workflow"}
	cmd.Flags().BoolVar(&tidy, "tidy", false, "Delete cluster after tests complete")
	cmd.Flags().IntVar(&workers, "workers", 1, "Number of worker nodes for kind clusters")
	cmd.RunE = func(cmd *cobra.Command, args []string) error {
		tp, err := plan.Load(testDir)
		if err != nil {
			return err
		}
		exists, err := clusterExists(tp)
		if err != nil {
			return err
		}
		if !exists {
			if err := clusterCreate(cmd, args); err != nil {
				return err
			}
		}
		if err := depsDeploy(cmd, args); err != nil {
			return err
		}
		if err := subjectDeploy(cmd, args); err != nil {
			return err
		}
		if err := testRun(cmd, args); err != nil {
			return err
		}
		if tidy {
			if err := clusterDelete(cmd, args); err != nil {
				return err
			}
		}
		return nil
	}
	return cmd
}
