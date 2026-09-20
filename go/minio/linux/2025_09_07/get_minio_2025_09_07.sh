#! /bin/bash
cd "$(dirname "$0")"
git clone https://github.com/minio/minio.git
cd minio
git checkout RELEASE.2025-09-07T16-13-09Z
go build
