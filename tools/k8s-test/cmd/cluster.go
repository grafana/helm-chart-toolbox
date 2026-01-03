package cmd

import (
	"fmt"
	"os"
	"os/exec"

	"github.com/grafana/helm-chart-toolbox/tools/k8s-test/internal/plan"
	"github.com/spf13/cobra"
)

func newCmdCluster() *cobra.Command {
	cmd := &cobra.Command{Use: "cluster", Short: "Cluster commands"}
	cmd.AddCommand(&cobra.Command{Use: "info", Short: "Show cluster info", RunE: clusterInfo})
	cmd.AddCommand(&cobra.Command{Use: "check", Short: "Check if cluster exists", RunE: clusterCheck})
	create := &cobra.Command{Use: "create", Short: "Create cluster", RunE: clusterCreate}
	create.Flags().IntVar(&workers, "workers", 1, "Number of worker nodes for kind clusters")
	cmd.AddCommand(create)
	cmd.AddCommand(&cobra.Command{Use: "delete", Short: "Delete cluster", RunE: clusterDelete})
	return cmd
}

func clusterInfo(cmd *cobra.Command, args []string) error {
	tp, err := plan.Load(testDir)
	if err != nil {
		return err
	}
	fmt.Fprintf(cmd.OutOrStdout(), "Name: %s\nType: %s\n", tp.ClusterName(), tp.Cluster.Type)
	return nil
}

func clusterCheck(cmd *cobra.Command, args []string) error {
	tp, err := plan.Load(testDir)
	if err != nil {
		return err
	}
	exists, err := clusterExists(tp)
	if err != nil {
		return err
	}
	if exists {
		fmt.Fprintln(cmd.OutOrStdout(), "present")
	} else {
		fmt.Fprintln(cmd.OutOrStdout(), "absent")
	}
	return nil
}

func clusterCreate(cmd *cobra.Command, args []string) error {
	tp, err := plan.Load(testDir)
	if err != nil {
		return err
	}
	switch tp.Cluster.Type {
	case "kind":
		args := []string{"create", "cluster", "--name", tp.ClusterName()}
		if tp.Cluster.ConfigFile != "" {
			args = append(args, "--config", tp.AbsPath(tp.Cluster.ConfigFile))
		} else {
			n := workers
			if n < 1 {
				n = 1
			}
			cfg := "kind: Cluster\napiVersion: kind.x-k8s.io/v1alpha4\nnodes:\n- role: control-plane\n"
			for i := 0; i < n; i++ {
				cfg += "- role: worker\n"
			}
			f, err := os.CreateTemp("", "kind-config-*.yaml")
			if err != nil {
				return err
			}
			defer os.Remove(f.Name())
			if _, err := f.WriteString(cfg); err != nil {
				return err
			}
			_ = f.Close()
			args = append(args, "--config", f.Name())
		}
		out, err := exec.Command("kind", args...).CombinedOutput()
		if err != nil {
			return fmt.Errorf("kind create: %w\n%s", err, string(out))
		}
	case "minikube":
		out, err := exec.Command("minikube", "start").CombinedOutput()
		if err != nil {
			return fmt.Errorf("minikube start: %w\n%s", err, string(out))
		}
	default:
		return fmt.Errorf("cluster type not yet supported: %s", tp.Cluster.Type)
	}
	return nil
}

func clusterDelete(cmd *cobra.Command, args []string) error {
	tp, err := plan.Load(testDir)
	if err != nil {
		return err
	}
	switch tp.Cluster.Type {
	case "kind":
		out, err := exec.Command("kind", "delete", "cluster", "--name", tp.ClusterName()).CombinedOutput()
		if err != nil {
			return fmt.Errorf("kind delete: %w\n%s", err, string(out))
		}
	case "minikube":
		out, err := exec.Command("minikube", "delete").CombinedOutput()
		if err != nil {
			return fmt.Errorf("minikube delete: %w\n%s", err, string(out))
		}
	default:
		return fmt.Errorf("cluster type not yet supported: %s", tp.Cluster.Type)
	}
	return nil
}

// clusterExists returns whether the referenced cluster exists
func clusterExists(tp *plan.TestPlan) (bool, error) {
	switch tp.Cluster.Type {
	case "kind":
		out, err := exec.Command("kind", "get", "clusters").CombinedOutput()
		if err != nil {
			return false, fmt.Errorf("kind get clusters: %w\n%s", err, string(out))
		}
		return plan.ContainsLine(string(out), tp.ClusterName()), nil
	case "minikube":
		out, _ := exec.Command("minikube", "status").CombinedOutput()
		return len(out) > 0, nil
	default:
		return false, nil
	}
}
