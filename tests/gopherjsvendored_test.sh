#!/bin/sh
# Don't run this file directly. It's executed as part of TestGopherJSCanBeVendored.

set -e

tmp=$(mktemp -d "${TMPDIR:-/tmp}/gopherjsvendored_test.XXXXXXXXXX")

cleanup() {
    rm -rf "$tmp"
    exit
}

trap cleanup EXIT HUP INT TERM

# Make a hello project that will vendor GopherJS.
mkdir -p "$tmp/src/example.org/hello"
echo 'package main

import "github.com/gopherjs/gopherjs/js"

func main() {
    js.Global.Get("console").Call("log", "hello using js pkg")
}' > "$tmp/src/example.org/hello/main.go"

# Vendor GopherJS and its dependencies into hello project.
mkdir -p "$tmp/src/example.org/hello/vendor/github.com/gopherjs" \
         "$tmp/src/example.org/hello/vendor/github.com/fsnotify" \
         "$tmp/src/example.org/hello/vendor/github.com/kisielk" \
         "$tmp/src/example.org/hello/vendor/github.com/neelance" \
         "$tmp/src/example.org/hello/vendor/github.com/shurcooL" \
         "$tmp/src/example.org/hello/vendor/github.com/spf13" \
         "$tmp/src/example.org/hello/vendor/golang.org/x"
cp -r $(go list -e -f '{{.Dir}}' github.com/gopherjs/gopherjs)  "$tmp/src/example.org/hello/vendor/github.com/gopherjs/gopherjs"
cp -r $(go list -e -f '{{.Dir}}' github.com/fsnotify/fsnotify)  "$tmp/src/example.org/hello/vendor/github.com/fsnotify/fsnotify"
cp -r $(go list -e -f '{{.Dir}}' github.com/kisielk/gotool)     "$tmp/src/example.org/hello/vendor/github.com/kisielk/gotool"
cp -r $(go list -e -f '{{.Dir}}' github.com/neelance/sourcemap) "$tmp/src/example.org/hello/vendor/github.com/neelance/sourcemap"
cp -r $(go list -e -f '{{.Dir}}' github.com/shurcooL/httpfs)    "$tmp/src/example.org/hello/vendor/github.com/shurcooL/httpfs"
cp -r $(go list -e -f '{{.Dir}}' github.com/spf13/cobra)        "$tmp/src/example.org/hello/vendor/github.com/spf13/cobra"
cp -r $(go list -e -f '{{.Dir}}' github.com/spf13/pflag)        "$tmp/src/example.org/hello/vendor/github.com/spf13/pflag"
cp -r $(go list -e -f '{{.Dir}}' golang.org/x/crypto)           "$tmp/src/example.org/hello/vendor/golang.org/x/crypto"
cp -r $(go list -e -f '{{.Dir}}' golang.org/x/sys)              "$tmp/src/example.org/hello/vendor/golang.org/x/sys"
cp -r $(go list -e -f '{{.Dir}}' golang.org/x/tools)            "$tmp/src/example.org/hello/vendor/golang.org/x/tools"

# Make $tmp our GOPATH workspace.
export GOPATH="$tmp"

# Build the vendored copy of GopherJS.
go install example.org/hello/vendor/github.com/gopherjs/gopherjs

# Use it to build and run the hello command.
(cd "$GOPATH/src/example.org/hello" && "$GOPATH/bin/gopherjs" run main.go)
