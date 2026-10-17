#!/usr/bin/env bash
set -euo pipefail

# nerdctl v2.4.1：containerd/nerdctl 当前最新稳定标签（2026-10-02 发版，v2.4.0 的 patch）。
# nerdctl 是 containerd 生态里的 docker CLI 兼容前端，和 go/containerd_v、go/runc_v、
# go/buildkit_v 三条分支组成同一条 containerd 运行时链路。
NERDCTL_TAG="v2.4.1"
NERDCTL_REPO="https://github.com/containerd/nerdctl.git"
GO_VERSION="1.26.9"

cd "$(dirname "$0")"

# 1. nerdctl 走 CGO_ENABLED=0 纯 Go 构建，不需要任何 C 库；
#    只装取源码与解包工具链需要的东西。
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
    git make ca-certificates curl wget tar

# 2. 固定 Go 工具链：v2.4.1 的 go.mod 声明 go 1.26.6，必须给 >= 1.26.6 的工具链。
GOARCH="$(dpkg --print-architecture)"
curl -fsSL -o /tmp/go.tar.gz "https://go.dev/dl/go${GO_VERSION}.linux-${GOARCH}.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf /tmp/go.tar.gz
rm -f /tmp/go.tar.gz
export PATH="/usr/local/go/bin:${PATH}"
export GOTOOLCHAIN=auto
go version

# 3. 取源码。v2.4.1 没有 vendor/ 目录，构建时需要联网拉 module，
#    所以保持默认 GOPROXY（不要设 GOFLAGS=-mod=vendor）。
rm -rf project
git clone --branch "${NERDCTL_TAG}" --depth 1 "${NERDCTL_REPO}" project
cd project
REVISION="$(git rev-parse HEAD)"
echo "HEAD => ${REVISION}"

# 4. 上游标准入口：默认目标 all -> binaries，产物 _output/nerdctl。
#    Makefile 里 VERSION/REVISION 由 git describe / git rev-parse 推导，
#    浅克隆下 describe 拿不到完整历史，这里显式传参，避免版本串悄悄退化成
#    no_git_information 或者带 .m 后缀。
make binaries VERSION="${NERDCTL_TAG}" REVISION="${REVISION}"

# 5. 产物校验
ls -lh _output/
file _output/nerdctl
./_output/nerdctl --version
