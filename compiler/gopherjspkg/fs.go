// +build gopherjsdev

package gopherjspkg

import (
	"go/build"
	"log"
	"net/http"
	"os"
	"strings"

	"github.com/shurcooL/httpfs/filter"
)

// FS is a virtual filesystem that contains core GopherJS packages.
var FS = filter.Keep(
	http.Dir(importPathToDir("github.com/gopherjs/gopherjs")),
	func(path string, fi os.FileInfo) bool {
		return path == "/" ||
			path == "/js" || strings.HasPrefix(path, "/js/") ||
			path == "/nosync" || strings.HasPrefix(path, "/nosync/")
	},
)

func importPathToDir(importPath string) string {
	p, err := build.Import(importPath, "", build.FindOnly)
	if err != nil {
		log.Fatalln(err)
	}
	return p.Dir
}
