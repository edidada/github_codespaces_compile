#!/usr/bin/env bash
set -euo pipefail

# k3s v1.37.1+k3s1：k3s-io/k3s 当前最新稳定标签（Kubernetes v1.37.1 的 k3s1 构建）。
# 上游 make binary / make ci 全部走 docker buildx（Dockerfile 里 golang:1.26.8-alpine3.24
# + tonistiigi/xx 交叉 + musl 静态链接），GitHub-hosted runner 上没有可用的 Docker
# （buildkit/containerd 分支已经踩过：cgroup v2 下 --privileged 起不来）。
# 这里不魔改构建逻辑，只把 Dockerfile 的 infra/manifests/build 三个 stage 里
# Linux amd64 那条腿的等价命令在宿主上依次跑一遍：
#   scripts/download -> scripts/build -> scripts/package-cli
K3S_TAG="v1.37.1+k3s1"
K3S_REPO="https://github.com/k3s-io/k3s.git"
# 与上游 Dockerfile 顶上的 ARG GOLANG=golang:1.26.8-alpine3.24 对齐
GO_VERSION="1.26.8"
YQ_VERSION="v4.44.3"

cd "$(dirname "$0")"

# 1. 系统依赖 = 上游 infra stage 的 apk add 列表换成 Debian 对应物：
#    build-essential(gcc/make) git curl ca-certificates zstd +
#    libseccomp-dev/libapparmor-dev/libselinux-dev（scripts/build 给 k3s、containerd-shim、
#    runc 三处都加了 seccomp/apparmor(/selinux) build tag）+ pkg-config。
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
    build-essential \
    git \
    make \
    curl \
    wget \
    tar \
    xz-utils \
    ca-certificates \
    zstd \
    pkg-config \
    libseccomp-dev \
    libapparmor-dev \
    libselinux-dev

# 2. Go 工具链（上游用 1.26.8；go.mod 里 `go 1.26.8`，低于这个版本直接拒编）
GOARCH="$(dpkg --print-architecture)"
curl -fsSL -o /tmp/go.tar.gz "https://go.dev/dl/go${GO_VERSION}.linux-${GOARCH}.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf /tmp/go.tar.gz
rm -f /tmp/go.tar.gz
export PATH="/usr/local/go/bin:${PATH}"
export GOTOOLCHAIN=auto
go version

# 3. scripts/download 会用 yq 解析 manifests 里的 HelmChart CRD 去抓 chart 资产，
#    apt 里的 yq 是 Python 版（不认 eval/--no-doc），必须装 mikefarah 的 Go 版。
if ! command -v yq >/dev/null 2>&1 || ! yq --version 2>&1 | grep -q mikefarah; then
    curl -fsSL -o /tmp/yq "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${GOARCH}"
    sudo install -m 0755 /tmp/yq /usr/local/bin/yq
    rm -f /tmp/yq
fi
yq --version

# 4. 取源码。tag 里有 `+`，git clone --branch 需要它原样传过去。
rm -rf project
git clone --branch "${K3S_TAG}" --depth 1 "${K3S_REPO}" project
cd project
COMMIT="$(git rev-parse HEAD)"
echo "HEAD => ${COMMIT}"

# 5. scripts/git_version.sh 会用 `git tag -l --contains HEAD` 推 GIT_TAG，
#    浅克隆下这一步不稳（tag 只有我们这一个，但 --contains 依赖 reflog），
#    直接按上游 Dockerfile 传 build-arg 的方式显式给。
#    scripts/version.sh 会校验 GIT_TAG 必须以 k8s.io/kubernetes 模块版本（去掉 -k3s*）
#    加 [+-] 开头，即 v1.37.1+ —— 对不上就直接 exit 1，所以这里传错等于立刻失败。
export GIT_TAG="${K3S_TAG}"
export COMMIT
export TREE_STATE=clean
export DIRTY=""
# Dockerfile infra stage 里的环境变量
export TARGETOS=linux
export TARGETARCH="${GOARCH}"
export SELINUX=true
# 关键差异：不设 STATIC_BUILD。上游在 alpine 里用 musl + *-static 包做 -extldflags '-static'，
# Ubuntu/glibc 上没有对应的 libseccomp/apparmor 静态包，静态化只会把构建拖进链接错误。
# 产物因此是动态链接的 glibc 版本（其余 tag 组合与上游一致）。
unset STATIC_BUILD || true

# 6. 依次跑上游脚本（就是 Dockerfile 的 manifests + build + package-cli 三个 stage）
./scripts/download
./scripts/build
./scripts/package-cli

# 7. 产物校验
echo "==== bin ===="
ls -lh bin/ | head -30
echo "==== dist/artifacts ===="
ls -lh dist/artifacts/
file bin/k3s
bin/k3s --version
# dist/artifacts/k3s 是那个自带 data tarball 的包装器（--version 不解压镜像内容）
dist/artifacts/k3s --version || echo "WARN: 包装器 k3s 运行 --version 失败（不影响 bin/k3s 产物）"

echo "完成：k3s ${K3S_TAG} 已从源码构建（无 Docker 路径）"
