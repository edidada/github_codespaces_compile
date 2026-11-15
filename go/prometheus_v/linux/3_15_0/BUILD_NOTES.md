# go/prometheus_v/linux/3_15_0

编译对象：**Prometheus**（CNCF 毕业项目，prometheus/prometheus）。

## 版本依据

- `gh api repos/prometheus/prometheus/releases/latest` → `v3.15.0`，published 2026-09-25。
- `go.mod` 里 `go 1.26.7`，`.promu.yml` 里 `go.version: 1.27`，上游 CI 用
  `quay.io/prometheus/golang-builder:1.27-base`。脚本装 go.dev 的 latest stable，
  保证 >= 1.27；promu 会按 `.promu.yml` 的版本走。
- `web/ui/.nvmrc` = `24.20.0`，即 UI 构建要求 node 主版本 24。
- `web/ui/pnpm-lock.yaml` 是 `lockfileVersion: '9.0'`，且 `web/ui/.npmrc` 用了
  `min-release-age=1` / `allow-git=none` 这类 pnpm 10.x 的策略项，所以 pnpm 装 10。
  仓库没有 `packageManager` 字段，所以走 `npm i -g pnpm@10` 而不是 corepack。

## 构建方式

按上游发布路径 `make build`，三段：

1. `assets` = `check-node-version`（只是 warn，不卡版本）+ `ui-install`
   （`pnpm install` 在 `web/ui` 和 `web/ui/react-app` 各跑一次）+ `ui-build`
   （`pnpm run build` → `build_ui.sh --all`：codemirror 模块、react-app、mantine-ui，
   产物挪进 `web/ui/static/`）。
2. `assets-compress` = `scripts/compress_assets.sh`：把 `static/` 逐文件 gzip，
   并由 `embed.go.tmpl` 生成 `web/ui/embed.go`（`//go:embed` 列出所有 `.gz`）。
3. `common-build` = `promu build --prefix $(pwd)`，
   `.promu.yml` 定义 binaries = `prometheus`(./cmd/prometheus) + `promtool`(./cmd/promtool)，
   tags = `netgo,builtinassets`，ldflags 注入 Version/Revision/Branch/BuildUser/BuildDate。

`PREFIX ?= $(shell pwd)`（Makefile.common:82），所以最终产物落在仓库根：`./prometheus`、`./promtool`。

## 为什么不用更省事的 go build

`go build ./cmd/prometheus` 能过（`ui.go` 的 `!builtinassets` 分支从磁盘读 `./web/ui/static`），
但那样出来的不是上游发布物：没有 `builtinassets` 内嵌，离开源码目录跑就没有 Web UI。
所以要的是 `make build` 那条完整链，代价是多装一套 node + pnpm。

## 验证内容

- `ls -lh prometheus promtool` + `file prometheus`
- `./prometheus --version`、`./promtool --version`（看 ldflags 是否真的注进去）
- `./promtool check config documentation/examples/prometheus.yml`
- 真启动一次：`--web.listen-address=127.0.0.1:19090` + 临时 tsdb 目录，
  轮询 `/-/healthy`（60s 超时），然后
  - `GET /` 必须返回含 `<html` 的页面 —— 这是 `builtinassets` 生效的直接证据
  - `GET /-/ready`
  - `GET /metrics` 里的 `prometheus_build_info`
  - `GET /api/v1/query?query=up`

## 已知限制 / 注意

- node 装到 `/opt/node` 并把属主 `chown` 给当前用户，`npm i -g pnpm` 因此不需要 sudo
  （`sudo` 会吞掉我们导出的 PATH，pnpm 会装到系统 node 上）。
- `pnpm install` 走 npm registry，需要外网；GitHub 托管 runner 直连没问题。
- `min-release-age=1` 意味着 pnpm 会拒装发布不满 1 天的包；对固定 tag 的依赖树没影响。
