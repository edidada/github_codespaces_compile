#!/usr/bin/env bash
set -euo pipefail

# runc v1.5.2：opencontainers/runc 当前最新稳定标签（1.6.0 还停在 rc.1）。
# 它是 containerd 默认的 low-level runtime，和 go/containerd_v 分支属于同一条运行时链路。
RUNC_TAG="v1.5.2"
RUNC_REPO="https://github.com/opencontainers/runc.git"
GO_VERSION="1.25.9"

cd "$(dirname "$0")"

# 1. 系统依赖：libseccomp-dev 是硬依赖（Makefile 会 test -e /usr/include/seccomp.h），
#    libc6-dev 提供 cgo 头文件，pkg-config 供 libseccomp 探测
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
    git gcc libc6-dev libseccomp-dev pkg-config \
    ca-certificates curl wget tar

# 2. 固定 Go 工具链：runc go.mod 要求 go >= 1.24.0，官方 CI 用 1.24.10 / 1.25.9
GOARCH="$(dpkg --print-architecture)"
curl -fsSL -o /tmp/go.tar.gz "https://go.dev/dl/go${GO_VERSION}.linux-${GOARCH}.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf /tmp/go.tar.gz
rm -f /tmp/go.tar.gz
export PATH="/usr/local/go/bin:${PATH}"
export GOTOOLCHAIN=auto
go version

# 3. 取源码。VERSION 由 git describe --match 'v[0-9]*' 推导，需要 annotated tag 对象在场，
#    所以用有限深度克隆，并在构建前断言 describe 的结果就是目标标签
rm -rf project
git clone --branch "${RUNC_TAG}" --depth 50 "${RUNC_REPO}" project
cd project
# 直接断言 git describe 的结果（VERSION 就是它推导出来的）。
# 注意不能用 test -f .git/refs/tags/<tag>：浅克隆会把 tag 写进 packed-refs，文件不存在。
DESCRIBED="$(git describe --match 'v[0-9]*')"
TAG_TYPE="$(git cat-file -t "refs/tags/${RUNC_TAG}")"
echo "git describe => ${DESCRIBED} (tag object type: ${TAG_TYPE})"
[ "${DESCRIBED}" = "${RUNC_TAG}" ] || {
    echo "FATAL: git describe 得到 ${DESCRIBED}，与目标标签 ${RUNC_TAG} 不符，注入的版本号会错" >&2
    exit 1
}

# 4. 上游标准构建入口。这里只跑 local，不跑默认的 verify：
#    verify 会先执行 script/git-check（要求容器里的 git 鉴权与 go mod vendor 提交），
#    裸 runner 环境用不上；libseccomp 版本检查（check-seccomp）已含在 local 内。
#    GOPROXY=dynamic 是因为 runc 对 containerd 用的是远端 pseudo-version replace，不需要本地源码。
make GOPROXY="https://proxy.golang.org,dynamic" local

# 5. 产物校验
ls -lh bin/
./bin/runc --version
