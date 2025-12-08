package cmd

import (
	"fmt"

	"github.com/grafana/helm-chart-toolbox/tools/k8s-test/internal/plan"
	"github.com/grafana/helm-chart-toolbox/tools/k8s-test/internal/sh"
	"github.com/spf13/cobra"
)

func newCmdSubject() *cobra.Command {
	cmd := &cobra.Command{Use: "subject", Short: "Subject commands"}
	cmd.AddCommand(&cobra.Command{Use: "info", Short: "Show subject info", RunE: subjectInfo})
	cmd.AddCommand(&cobra.Command{Use: "deploy", Short: "Deploy subject", RunE: subjectDeploy})
	cmd.AddCommand(&cobra.Command{Use: "upgrade", Short: "Upgrade subject", RunE: subjectUpgrade})
	cmd.AddCommand(&cobra.Command{Use: "delete", Short: "Delete subject", RunE: subjectDelete})
	return cmd
}

func subjectInfo(cmd *cobra.Command, args []string) error {
	tp, err := plan.Load(testDir)
	if err != nil {
		return err
	}
	fmt.Fprintf(cmd.OutOrStdout(), "Type: %s\nNamespace: %s\n", tp.Subject.Type, tp.Subject.Namespace)
	return nil
}

func subjectDeploy(cmd *cobra.Command, args []string) error {
	tp, err := plan.Load(testDir)
	if err != nil {
		return err
	}
	nsArgs := []string{}
	if tp.Subject.Namespace != "" {
		nsArgs = []string{"--namespace", tp.Subject.Namespace, "--create-namespace"}
	}
	subjectType := tp.Subject.Type
	if subjectType == "" {
		subjectType = "helm"
	}
	switch subjectType {
	case "manifest":
		return sh.Run(cmd, "kubectl", append([]string{"apply", "-f", tp.AbsPath(tp.Subject.Path)}, nsArgs...)...)
	case "helm":
		releaseName := tp.Subject.ReleaseNameOrDefault(tp.Name)
		chartArg := []string{}
		if tp.Subject.Path != "" {
			chartArg = []string{tp.AbsPath(tp.Subject.Path)}
		} else if tp.Subject.Chart != "" && tp.Subject.Repository != "" {
			chartArg = []string{"--repo", tp.Subject.Repository, tp.Subject.Chart}
		} else {
			return fmt.Errorf("subject requires either path or (repository+chart)")
		}
		valuesArgs := []string{}
		if tp.Subject.ValuesFile != "" {
			valuesArgs = append(valuesArgs, "-f", tp.AbsPath(tp.Subject.ValuesFile))
		}
		if len(tp.Subject.Values) > 0 {
			valuesArgs = append(valuesArgs, "-f", sh.TempFileWithContent(plan.ToYAML(tp.Subject.Values)))
		}
		args := []string{"upgrade", "--install", "--wait", releaseName}
		args = append(args, chartArg...)
		args = append(args, nsArgs...)
		args = append(args, valuesArgs...)
		return sh.Run(cmd, "helm", args...)
	default:
		return fmt.Errorf("unsupported subject type: %s", tp.Subject.Type)
	}
}

func subjectUpgrade(cmd *cobra.Command, args []string) error { return subjectDeploy(cmd, args) }

func subjectDelete(cmd *cobra.Command, args []string) error {
	tp, err := plan.Load(testDir)
	if err != nil {
		return err
	}
	subjectType := tp.Subject.Type
	if subjectType == "" {
		subjectType = "helm"
	}
	switch subjectType {
	case "manifest":
		return sh.Run(cmd, "kubectl", "delete", "-f", tp.AbsPath(tp.Subject.Path))
	case "helm":
		nsArgs := []string{}
		if tp.Subject.Namespace != "" {
			nsArgs = []string{"--namespace", tp.Subject.Namespace}
		}
		return sh.Run(cmd, "helm", append([]string{"uninstall", tp.Subject.ReleaseNameOrDefault(tp.Name)}, nsArgs...)...)
	default:
		return fmt.Errorf("unsupported subject type: %s", tp.Subject.Type)
	}
}
