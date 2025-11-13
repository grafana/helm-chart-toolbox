package cmd

import (
	"fmt"
	"io/fs"
	"path/filepath"

	"github.com/grafana/helm-chart-toolbox/tools/k8s-test/internal/helmtestfs"
	"github.com/grafana/helm-chart-toolbox/tools/k8s-test/internal/plan"
	"github.com/grafana/helm-chart-toolbox/tools/k8s-test/internal/sh"
	"github.com/spf13/cobra"
)

func newCmdDeps() *cobra.Command {
	cmd := &cobra.Command{Use: "deps", Short: "Dependency operations"}
	cmd.AddCommand(&cobra.Command{Use: "list", Short: "List embedded presets", RunE: depsList})
	cmd.AddCommand(&cobra.Command{Use: "deploy", Short: "Deploy dependencies (embedded)", RunE: depsDeploy})
	return cmd
}

func depsList(cmd *cobra.Command, args []string) error {
	f := helmtestfs.FS()
	return fs.WalkDir(f, "presets", func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if d.IsDir() {
			return nil
		}
		if filepath.Ext(path) == ".yaml" {
			fmt.Fprintln(cmd.OutOrStdout(), path)
		}
		return nil
	})
}

func depsDeploy(cmd *cobra.Command, args []string) error {
	f := helmtestfs.FS()
	tp, err := plan.Load(testDir)
	if err != nil {
		return err
	}

	// Ensure Flux controllers are installed (idempotent)
	if err := sh.Run(cmd, "flux", "install", "--components=source-controller,helm-controller"); err != nil {
		return err
	}

	// Apply only the dependencies requested in the test plan
	for i := range tp.Dependencies {
		dep := tp.Dependencies[i]
		switch dep.Preset {
		case "grafana":
			if err := apply(f, cmd, "presets/helm-repository-grafana.yaml"); err != nil {
				return err
			}
			if err := apply(f, cmd, "presets/namespace-grafana.yaml"); err != nil {
				return err
			}
			if err := apply(f, cmd, "presets/preset-grafana.yaml"); err != nil {
				return err
			}
		case "prometheus":
			if err := apply(f, cmd, "presets/helm-repository-prometheus.yaml"); err != nil {
				return err
			}
			if err := apply(f, cmd, "presets/namespace-prometheus.yaml"); err != nil {
				return err
			}
			if err := apply(f, cmd, "presets/preset-prometheus.yaml"); err != nil {
				return err
			}
		case "loki":
			if err := apply(f, cmd, "presets/helm-repository-grafana.yaml"); err != nil {
				return err
			}
			if err := apply(f, cmd, "presets/namespace-loki.yaml"); err != nil {
				return err
			}
			if err := apply(f, cmd, "presets/preset-loki.yaml"); err != nil {
				return err
			}
		case "tempo":
			if err := apply(f, cmd, "presets/helm-repository-grafana.yaml"); err != nil {
				return err
			}
			if err := apply(f, cmd, "presets/namespace-tempo.yaml"); err != nil {
				return err
			}
			if err := apply(f, cmd, "presets/preset-tempo.yaml"); err != nil {
				return err
			}
		case "pyroscope":
			if err := apply(f, cmd, "presets/helm-repository-grafana.yaml"); err != nil {
				return err
			}
			if err := apply(f, cmd, "presets/namespace-pyroscope.yaml"); err != nil {
				return err
			}
			if err := apply(f, cmd, "presets/preset-pyroscope.yaml"); err != nil {
				return err
			}
		}
		if dep.Directory != "" {
			if err := sh.Run(cmd, "kubectl", "apply", "-f", tp.AbsPath(dep.Directory)); err != nil {
				return err
			}
		}
		if dep.File != "" {
			if err := sh.Run(cmd, "kubectl", "apply", "-f", tp.AbsPath(dep.File)); err != nil {
				return err
			}
		}
		if dep.URL != "" {
			if err := sh.Run(cmd, "kubectl", "apply", "-f", dep.URL); err != nil {
				return err
			}
		}
		if dep.Manifest != "" {
			if err := sh.KubectlApplyYAML(cmd, dep.Manifest); err != nil {
				return err
			}
		}
	}

	// Install toolbox test packages only if referenced in tests
	hasQuery := false
	hasK8sObjs := false
	hasDelay := false
	for _, t := range tp.Tests {
		switch t.Type {
		case "query-test":
			hasQuery = true
		case "kubernetes-objects-test":
			hasK8sObjs = true
		case "delay":
			hasDelay = true
		}
	}
	if hasQuery || hasK8sObjs || hasDelay {
		if err := apply(f, cmd, "tests/namespace-toolbox.yaml"); err != nil {
			return err
		}
		if err := apply(f, cmd, "tests/helm-repository-toolbox.yaml"); err != nil {
			return err
		}
	}
	if hasQuery {
		if err := apply(f, cmd, "tests/helmrelease-query-test.yaml"); err != nil {
			return err
		}
	}
	if hasK8sObjs {
		if err := apply(f, cmd, "tests/helmrelease-kubernetes-objects-test.yaml"); err != nil {
			return err
		}
	}
	if hasDelay {
		if err := apply(f, cmd, "tests/helmrelease-delay.yaml"); err != nil {
			return err
		}
	}

	return nil
}

func apply(f fs.FS, cmd *cobra.Command, path string) error {
	b, err := fs.ReadFile(f, path)
	if err != nil {
		return err
	}
	return sh.KubectlApplyYAML(cmd, string(b))
}
