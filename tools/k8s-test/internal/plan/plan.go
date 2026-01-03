package plan

import (
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	yaml "gopkg.in/yaml.v3"
)

type TestPlan struct {
	APIVersion string `yaml:"apiVersion"`
	Kind       string `yaml:"kind"`
	Name       string `yaml:"name"`

	Cluster struct {
		Type       string `yaml:"type"`
		Name       string `yaml:"name"`
		AppendRand bool   `yaml:"appendRandomNumber"`
		Config     any    `yaml:"config"`
		ConfigFile string `yaml:"configFile"`
	} `yaml:"cluster"`

	Dependencies []Dependency `yaml:"dependencies"`
	Subject      Subject      `yaml:"subject"`
	Tests        []Test       `yaml:"tests"`

	dir string
}

type Dependency struct {
	Preset    string `yaml:"preset"`
	Overrides any    `yaml:"overrides"`
	Directory string `yaml:"directory"`
	File      string `yaml:"file"`
	URL       string `yaml:"url"`
	Manifest  string `yaml:"manifest"`
	Namespace string `yaml:"namespace"`
}

type Subject struct {
	Type       string         `yaml:"type"`
	Path       string         `yaml:"path"`
	Repository string         `yaml:"repository"`
	Chart      string         `yaml:"chart"`
	Version    string         `yaml:"version"`
	Release    string         `yaml:"releaseName"`
	Namespace  string         `yaml:"namespace"`
	Values     map[string]any `yaml:"values"`
	ValuesFile string         `yaml:"valuesFile"`
	Set        []SetDirective `yaml:"set"`
}

type SetDirective struct {
	Key       string `yaml:"key"`
	Value     string `yaml:"value"`
	ValueFrom string `yaml:"valueFrom"`
}

type Test struct {
	Type   string         `yaml:"type"`
	Values map[string]any `yaml:"values"`
}

func Load(dir string) (*TestPlan, error) {
	if dir == "" {
		wd, _ := os.Getwd()
		dir = wd
	}
	b, err := os.ReadFile(filepath.Join(dir, "test-plan.yaml"))
	if err != nil {
		return nil, fmt.Errorf("read test-plan.yaml: %w", err)
	}
	var tp TestPlan
	if err := yaml.Unmarshal(b, &tp); err != nil {
		return nil, fmt.Errorf("parse test-plan.yaml: %w", err)
	}
	if tp.Kind != "TestPlan" {
		return nil, errors.New("not a TestPlan document")
	}
	tp.dir = dir
	return &tp, nil
}

func (t *TestPlan) AbsPath(p string) string {
	if p == "" {
		return ""
	}
	if strings.HasPrefix(p, "oci://") {
		return p
	}
	if filepath.IsAbs(p) {
		return p
	}
	return filepath.Join(t.dir, p)
}

func (t *TestPlan) ClusterName() string {
	name := t.Cluster.Name
	if name == "" {
		name = t.Name + "-test-cluster"
	}
	if t.Cluster.AppendRand {
		path := filepath.Join(t.dir, ".random")
		data, err := os.ReadFile(path)
		var rand string
		if err == nil {
			rand = strings.TrimSpace(string(data))
		} else {
			rand = fmt.Sprintf("%06d", os.Getpid()%900000+100000)
			_ = os.WriteFile(path, []byte(rand), 0o644)
		}
		name = fmt.Sprintf("%s-%s", name, rand)
	}
	return name
}

func (s Subject) ReleaseNameOrDefault(planName string) string {
	if s.Release != "" {
		return s.Release
	}
	return planName
}

func ToYAML(v any) string {
	b, _ := yaml.Marshal(v)
	return string(b)
}

// ContainsLine returns true if any line equals needle after trimming.
func ContainsLine(haystack, needle string) bool {
	for _, l := range strings.Split(haystack, "\n") {
		if strings.TrimSpace(l) == needle {
			return true
		}
	}
	return false
}
