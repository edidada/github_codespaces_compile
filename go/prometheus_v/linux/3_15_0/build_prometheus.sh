#!/bin/bash
# Prometheus v3.15.0（CNCF 毕业项目 prometheus/prometheus 当前最新稳定 release，2026-09-25）
#
# 走上游正式发布路径：make build = assets(pnpm 构建 UI) -> assets-compress -> common-build(promu)。
# 为什么不能只 go build：.promu.yml 里 build.tags.all = [netgo, builtinassets]，
# builtinassets 需要 scripts/compress_assets.sh 生成的 web/ui/embed.go + static/*.gz，
# 而 static/ 来自 pnpm 构建的 mantine-ui / react-app / codemirror 模块。
# 直接 go build ./cmd/prometheus 也能出二进制（ui.go 的 !builtinassets 分支从磁盘读
# ./web/ui/static），但那不是上游发布物、UI 没内嵌，所以这里按 make build 全跑。
#
# Makefile.common 里 PREFIX ?= $(shell pwd)，所以产物就落在仓库根：./prometheus ./promtool。
set -euo pipefail

PROMETHEUS_TAG="${PROMETHEUS_TAG:-v3.15.0}"
PROMETHEUS_REPO="${PROMETHEUS_REPO:-https://github.com/prometheus/prometheus.git}"
# web/ui/.npmrc 用了 min-release-age / allow-git 这类 pnpm 10.x 才认识的策略项，
# 所以 pnpm 主版本必须 >=10；可用 PNPM_MAJOR 覆盖。
PNPM_MAJOR="${PNPM_MAJOR:-10}"
# 上游 CI 用 quay.io/prometheus/golang-builder:1.27-base（即 .promu.yml 的 go.version）。
# 留空 = 用 go.dev 的 latest stable，保证 >= 上游要求。
FORCE_GO_VERSION="${FORCE_GO_VERSION:-}"

echo "==== 目标 ===="
echo "PROMETHEUS_TAG = ${PROMETHEUS_TAG}"

# 1. 系统依赖。build-essential 是给可能的 cgo 编译兜底（promu 自己也是 go build 出来的）。
sudo apt-get update -y
sudo apt-get install -y --no-install-recommends \
    git curl wget tar xz-utils unzip ca-certificates make build-essential

# 2. 先 clone：Go / Node 的版本要从仓库里的 .promu.yml 和 web/ui/.nvmrc 读出来。
rm -rf project
git -c core.autocrlf=false clone --branch "${PROMETHEUS_TAG}" --depth 1 "${PROMETHEUS_REPO}" project
cd project
echo "HEAD = $(git rev-parse HEAD)"
echo "describe = $(git describe --tags --match 'v*')"

# 3. Go。
GO_SERIES="$(awk '/^go:/{f=1;next} f && /version:/{gsub(/[^0-9.]/,"",$2); print $2; exit}' .promu.yml)"
if [ -n "${FORCE_GO_VERSION}" ]; then
    GO_VERSION_NUM="${FORCE_GO_VERSION}"
else
    curl -fsSL 'https://go.dev/VERSION?m=text' -o /tmp/go-version.txt
    GO_VERSION_NUM="$(sed -n '1p' /tmp/go-version.txt)"
    GO_VERSION_NUM="${GO_VERSION_NUM#go}"
fi
[ -n "${GO_VERSION_NUM}" ] || { echo "FATAL: 拿不到 Go 版本" >&2; exit 1; }
GOARCH_NAME="$(dpkg --print-architecture)"
echo "==== 安装 Go ${GO_VERSION_NUM}（.promu.yml 要求 ${GO_SERIES}）===="
curl -fsSL "https://go.dev/dl/go${GO_VERSION_NUM}.linux-${GOARCH_NAME}.tar.gz" -o /tmp/go.tgz
sudo rm -rf /usr/local/go
sudo tar -xzf /tmp/go.tgz -C /usr/local
export PATH="/usr/local/go/bin:${PATH}"
export GOTOOLCHAIN=auto
go version

# 4. Node + pnpm（构建 UI 用）。主版本跟着 web/ui/.nvmrc 走。
NODE_MAJOR="$(cut -d. -f1 web/ui/.nvmrc | tr -d 'v')"
[ -n "${NODE_MAJOR}" ] || { echo "FATAL: 读不到 web/ui/.nvmrc 的 node 主版本" >&2; exit 1; }
echo "==== 安装 Node ${NODE_MAJOR}.x + pnpm ${PNPM_MAJOR}.x ===="
curl -fsSL "https://nodejs.org/dist/latest-v${NODE_MAJOR}.x/" -o /tmp/node-index.html
# 用 grep -m1 直接读文件，不要 curl|grep|head —— pipefail 下 head 提前关管道会制造假失败。
NODE_TARBALL="$(grep -m1 -o "node-v[0-9][0-9.]*-linux-${GOARCH_NAME}.tar.gz" /tmp/node-index.html)"
[ -n "${NODE_TARBALL}" ] || { echo "FATAL: nodejs.org 上找不到 v${NODE_MAJOR}.x 的 linux-${GOARCH_NAME} tarball" >&2; exit 1; }
curl -fsSL "https://nodejs.org/dist/latest-v${NODE_MAJOR}.x/${NODE_TARBALL}" -o /tmp/node.tgz
sudo mkdir -p /opt/node
sudo rm -rf /opt/node
sudo mkdir -p /opt/node
# 解出来的目录属主改成当前用户，npm -g 就不需要 sudo（sudo 会吞掉 PATH 里的 node）。
sudo tar -xzf /tmp/node.tgz -C /opt/node --strip-components=1 --owner=0 --group=0
sudo chown -R "$(id -u):$(id -g)" /opt/node
export PATH="/opt/node/bin:${PATH}"
echo "node   = $(node --version)"
echo "npm    = $(npm --version)"
npm install -g "pnpm@${PNPM_MAJOR}"
echo "pnpm   = $(pnpm --version)"

# 5. 构建。
#    assets -> check-node-version(只是 warn) + ui-install(pnpm install，web/ui 和
#    web/ui/react-app 各一次) + ui-build(pnpm run build = build_ui.sh --all)，
#    assets-compress 生成 web/ui/embed.go + static/*.gz，
#    最后 promu build --prefix . 产出 ./prometheus ./promtool。
echo "==== make build ===="
make build

# 6. 产物校验。
ls -lh prometheus promtool
file prometheus
echo "==== 版本信息（ldflags 注入 version/revision/branch/builduser/builddate）===="
./prometheus --version
./promtool --version

# 7. 冒烟：真的把 prometheus 跑起来，验证内嵌 UI（builtinassets）+ TSDB + HTTP 全通。
#    这一步能证伪「embed.go 没生成、静态资源是空的」这类假成功。
CONF="documentation/examples/prometheus.yml"
./promtool check config "${CONF}"

DATA_DIR="$(mktemp -d)"
LOG="${DATA_DIR}/prometheus.log"
./prometheus \
    --config.file="${CONF}" \
    --storage.tsdb.path="${DATA_DIR}/tsdb" \
    --web.listen-address=127.0.0.1:19090 \
    > "${LOG}" 2>&1 &
PROM_PID=$!
cleanup() {
    kill "${PROM_PID}" 2>/dev/null || true
    wait "${PROM_PID}" 2>/dev/null || true
}
trap cleanup EXIT

ready=0
for _ in $(seq 1 60); do
    if curl -fsS "http://127.0.0.1:19090/-/healthy" >/dev/null 2>&1; then ready=1; break; fi
    sleep 1
done
if [ "${ready}" != 1 ]; then
    echo "FATAL: prometheus 60s 内没就绪，启动日志：" >&2
    tail -40 "${LOG}" >&2
    exit 1
fi
echo "==== /-/healthy 通过，启动日志摘要 ===="
head -20 "${LOG}"

echo "==== 内嵌 UI（builtinassets）===="
curl -fsS "http://127.0.0.1:19090/" -o "${DATA_DIR}/index.html"
head -c 300 "${DATA_DIR}/index.html"; echo
if grep -qi '<html' "${DATA_DIR}/index.html"; then
    echo "UI HTML 正常返回，字节数 = $(wc -c < "${DATA_DIR}/index.html")"
else
    echo "FATAL: / 没有返回 HTML，说明 UI 没内嵌成功" >&2
    exit 1
fi
curl -fsS "http://127.0.0.1:19090/-/ready" >/dev/null && echo "/-/ready 正常"
echo "==== build info ===="
curl -fsS "http://127.0.0.1:19090/metrics" -o "${DATA_DIR}/metrics.txt"
grep -F 'prometheus_build_info' "${DATA_DIR}/metrics.txt"
echo "==== 查询接口 ===="
curl -fsS "http://127.0.0.1:19090/api/v1/query?query=up" -o "${DATA_DIR}/query.json"
head -c 300 "${DATA_DIR}/query.json"; echo

cleanup
trap - EXIT

echo "完成：Prometheus ${PROMETHEUS_TAG} 已从源码构建（make build，含内嵌 UI）"
