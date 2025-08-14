package sh

import (
	"os"
)

// TempFileWithContent writes content to a temp file and returns its path.
func TempFileWithContent(content string) string {
	f, _ := os.CreateTemp("", "k8s-test-*.yaml")
	f.WriteString(content)
	f.Close()
	return f.Name()
}
