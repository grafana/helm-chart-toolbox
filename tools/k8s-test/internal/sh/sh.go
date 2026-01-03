package sh

import (
	"fmt"
	"os"
	"os/exec"
	"strings"

	"github.com/spf13/cobra"
)

func Run(cmd *cobra.Command, name string, args ...string) error {
	fmt.Fprintln(cmd.OutOrStdout(), strings.Join(append([]string{name}, args...), " "))
	c := exec.Command(name, args...)
	c.Stdout = cmd.OutOrStdout()
	c.Stderr = cmd.ErrOrStderr()
	return c.Run()
}

func KubectlApplyYAML(cmd *cobra.Command, yaml string) error {
	f, err := os.CreateTemp("", "k8s-test-*.yaml")
	if err != nil {
		return err
	}
	defer os.Remove(f.Name())
	if _, err := f.WriteString(yaml); err != nil {
		return err
	}
	_ = f.Close()
	return Run(cmd, "kubectl", "apply", "-f", f.Name())
}
