#!/usr/bin/env bash
set -euo pipefail

# containerd v2.2.3-k3s1 是 K3s 团队维护的 containerd 定制版：
# 基于上游 containerd v2.2.3，叠加 k3s 专属补丁后由 k3s-io/containerd 分叉仓库发布，
# Go 模块路径仍是 github.com/containerd/containerd/v2（并非 containerd 官方原版标签）。
CONTAINERD_TAG="v2.2.3-k3s1"
CONTAINERD_REPO="https://github.com/k3s-io/containerd.git"
GO_VERSION="1.25.9"

cd "$(dirname "$0")"

# 1. 构建依赖：git 取源码，gcc/make 支撑 make 的 -buildmode=pie 与 shim 链接
sudo apt-get update
sudo apt-get install -y --no-install-recommends git gcc make pkg-config ca-certificates curl wget tar

# 2. 显式安装 Go 工具链：该 tag 的 go.mod 声明 go 1.25.7，
#    1.25.9 正是 containerd 自身 CI 在 v2.2.3 上使用的版本，避免依赖 runner 预装版本
GOARCH="$(dpkg --print-architecture)"
curl -fsSL -o /tmp/go.tar.gz "https://go.dev/dl/go${GO_VERSION}.linux-${GOARCH}.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf /tmp/go.tar.gz
rm -f /tmp/go.tar.gz
export PATH="/usr/local/go/bin:${PATH}"
export GOTOOLCHAIN=auto
go version

# 3. 取源码。v2.2.3-k3s1 是轻量标签（不是 annotated tag），
#    浅克隆里 git describe 找不到它，所以下面把版本字符串显式传给 make
rm -rf project
git clone --depth 1 --branch "${CONTAINERD_TAG}" "${CONTAINERD_REPO}" project
cd project
git rev-parse HEAD

# 4. 上游标准构建入口：build 编译全部 Go 包，binaries 产出 bin/ 下的可执行文件
make build VERSION="${CONTAINERD_TAG}"
make binaries VERSION="${CONTAINERD_TAG}"

# 5. 产物校验
ls -lh bin/
./bin/containerd --version
./bin/ctr --version
