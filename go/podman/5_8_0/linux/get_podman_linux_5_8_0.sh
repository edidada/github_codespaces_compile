#! /bin/bash
cd "$(dirname "$0")"
git clone https://github.com/containers/podman.git
cd podman
git checkout v5.8.0
go mod tidy
go build -v ./...