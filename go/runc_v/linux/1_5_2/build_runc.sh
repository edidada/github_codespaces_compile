#!/usr/bin/env bash
set -euo pipefail

# runc v1.5.2：opencontainers/runc 当前最新稳定标签（1.6.0 还停在 rc.1）。
# 它是 containerd 默认的 low-level runtime，和 go/containerd_v 分支属于同一条运行时链路。
RUNC_TAG="v1.5.2"
RUNC_REPO="https://github.com/opencontainers/runc.git"
GO_VERSION="1.26.9"

cd "$(dirname "$0")"

# 1. 系统依赖按 README 的 Linux 一节：make gcc linux-libc-dev libseccomp-dev pkg-config git。
#    libgpgme 只有 release 签名才需要，构建不需要。
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
    make gcc linux-libc-dev libseccomp-dev pkg-config \
    git ca-certificates curl wget tar

# 2. 固定 Go 工具链：runc v1.5.2 的 go.mod 要求 go >= 1.25.0，上游 CI 跑 1.26.x / 1.27.x
GOARCH="$(dpkg --print-architecture)"
curl -fsSL -o /tmp/go.tar.gz "https://go.dev/dl/go${GO_VERSION}.linux-${GOARCH}.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf /tmp/go.tar.gz
rm -f /tmp/go.tar.gz
export PATH="/usr/local/go/bin:${PATH}"
export GOTOOLCHAIN=auto
go version

# 3. 取源码。COMMIT 由 `git describe --dirty --long --always` 注入 ldflags，
#    这里断言 describe 结果就是目标标签，避免版本信息悄悄跑偏。
#    注意不能写成 test -f .git/refs/tags/<tag>：浅克隆会把 tag 放进 packed-refs。
rm -rf project
git clone --branch "${RUNC_TAG}" --depth 50 "${RUNC_REPO}" project
cd project
COMMIT_DESC="$(git describe --dirty --long --always)"
echo "git describe --long => ${COMMIT_DESC}"
[ "${COMMIT_DESC#"$RUNC_TAG"}" != "$COMMIT_DESC" ] || {
    echo "FATAL: describe 结果 ${COMMIT_DESC} 不以 ${RUNC_TAG} 开头，注入的版本会错" >&2
    exit 1
}

# 4. 上游标准入口。v1.5.2 的默认目标就是 runc（产物 ./runc，动态 PIE），
#    这个 tag 里没有 local / binaries 目标。
#    默认 BUILDTAGS 含 libpathrs，它需要 Rust 的 libpathrs（apt 无包），
#    上游 CI 自己也用 RUNC_BUILDTAGS=-libpathrs 去掉，所以不算魔改；seccomp 标签保留。
make RUNC_BUILDTAGS=-libpathrs

# 5. 产物校验
ls -lh runc
file runc
./runc --version
