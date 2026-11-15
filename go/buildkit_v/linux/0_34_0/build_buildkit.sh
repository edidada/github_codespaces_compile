#!/usr/bin/env bash
set -euo pipefail

# buildkit v0.34.0：moby/buildkit 当前最新稳定标签（v0.34.0-rc2 之后正式发版）。
BUILDKIT_TAG="v0.34.0"
BUILDKIT_REPO="https://github.com/moby/buildkit.git"
GO_VERSION="1.26.9"
PACKAGE="github.com/moby/buildkit"

cd "$(dirname "$0")"

# 1. buildkit 纯 Go 构建不需要任何 C 库（vendored 的 seccomp 实现是 Go 的），
#    这里只装取源码与解包工具链需要的东西
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
    git make ca-certificates curl wget tar

# 2. 固定 Go 工具链：v0.34.0 的 go.mod 声明 go 1.26.8，必须给 >= 1.26.8 的工具链
GOARCH="$(dpkg --print-architecture)"
curl -fsSL -o /tmp/go.tar.gz "https://go.dev/dl/go${GO_VERSION}.linux-${GOARCH}.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf /tmp/go.tar.gz
rm -f /tmp/go.tar.gz
export PATH="/usr/local/go/bin:${PATH}"
export GOTOOLCHAIN=auto
go version

# 3. 取源码（depth 1 够用：仓库带 vendor/，版本字符串由下面显式传入）
rm -rf project
git clone --branch "${BUILDKIT_TAG}" --depth 1 "${BUILDKIT_REPO}" project
cd project
REVISION="$(git rev-parse HEAD)"
echo "HEAD => ${REVISION}"
if [ -d vendor ]; then
    echo "vendor/ 存在，使用 -mod=vendor 离线构建"
    export GOFLAGS="-mod=vendor"
fi

# 4. 上游的 make binaries 走 docker buildx bake，GitHub-hosted runner 上没有可用的
#    Docker/buildx，因此复刻 Dockerfile 里 buildctl / buildkitd 两个 build stage 的
#    等价命令：CGO_ENABLED=0 的 go build，版本信息用 version 包里的 ldflags 变量注入。
LDFLAGS="-s -w -X ${PACKAGE}/version.Version=${BUILDKIT_TAG} -X ${PACKAGE}/version.Revision=${REVISION} -X ${PACKAGE}/version.Package=${PACKAGE}"

mkdir -p bin
CGO_ENABLED=0 go build -ldflags "${LDFLAGS}" -o bin/buildctl ./cmd/buildctl
# buildkitd 按 Dockerfile 的方式带上 osusergo/netgo/seccomp 标签
CGO_ENABLED=0 go build -ldflags "${LDFLAGS}" -tags "osusergo netgo seccomp" -o bin/buildkitd ./cmd/buildkitd

# 5. 产物校验
ls -lh bin/
./bin/buildctl --version
./bin/buildkitd --version
