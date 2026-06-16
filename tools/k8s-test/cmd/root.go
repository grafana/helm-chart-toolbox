package cmd

import (
	"github.com/spf13/cobra"
)

var testDir string

func Execute() error { return newRoot().Execute() }

func newRoot() *cobra.Command {
	cmd := &cobra.Command{Use: "k8s-test", Short: "Helm chart test runner"}
	cmd.PersistentFlags().StringVarP(&testDir, "test-dir", "d", "", "Directory containing test-plan.yaml (default: cwd)")
	cmd.AddCommand(newCmdRun())
	cmd.AddCommand(newCmdCluster())
	cmd.AddCommand(newCmdDeps())
	cmd.AddCommand(newCmdSubject())
	cmd.AddCommand(newCmdTest())
	return cmd
}
