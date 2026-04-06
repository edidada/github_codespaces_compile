#! /bin/bash
cd "$(dirname "$0")"
sudo apt update
sudo apt install -y \
    libsqlite3-dev \
    libgpgme-dev \
    libseccomp-dev \
    libdevmapper-dev \
    btrfs-progs \
    gcc \
    make \
    pkg-config \
    btrfs-progs \
    libbtrfs-dev \
    libsystemd-dev
git clone https://github.com/containers/podman.git
cd podman
git checkout v5.8.0
go mod tidy
go build -v ./...
go build -v -o bin/podman ./cmd/podman
make BUILDTAGS="seccomp systemd"