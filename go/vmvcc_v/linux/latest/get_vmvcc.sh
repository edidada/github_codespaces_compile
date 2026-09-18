#! /bin/bash
cd "$(dirname "$0")"
git clone https://github.com/edidada/vmvcc.git
cd vmvcc
go get github.com/mit-pdos/vmvcc/txn
go mod tidy
go build
go test ./...
