package helmtestfs

import (
	"embed"
	"io/fs"
)

//go:embed manifests
var embedded embed.FS

// FS returns the embedded filesystem root at manifests/.
func FS() fs.FS {
	sub, _ := fs.Sub(embedded, "manifests")
	return sub
}
