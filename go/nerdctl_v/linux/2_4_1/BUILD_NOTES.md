# nerdctl v2.4.1（Linux）

## 版本选择

`v2.4.1` 是 containerd/nerdctl 当前最新稳定标签（2026-10-02 发布），tag 列表里 v2.4.0
之后只有 beta/rc 之外的这一个 patch 版本，因此选它。模块路径是
`github.com/containerd/nerdctl/v2`。

## 上游构建方式

`make` 默认目标 `all: binaries`，`binaries` 只有一个产物：

```make
binaries: $(CURDIR)/_output/$(BINARY)$(BIN_EXT)
$(CURDIR)/_output/$(BINARY)$(BIN_EXT):
	$(GO_BUILD) $(GO_BUILD_FLAGS) -o $(CURDIR)/_output/$(BINARY)$(BIN_EXT) ./cmd/nerdctl
# GO_BUILD = CGO_ENABLED=0 GOOS=$(GOOS) go -C $(MAKEFILE_DIR) build $(GO_TAGS) \
#            -ldflags "-s -w -X $(PACKAGE)/pkg/version.Version=$(VERSION) -X .../Revision=$(REVISION)"
```

所以脚本直接 `make binaries`，产物落 `project/_output/nerdctl`，版本串由
`pkg/version` 的 ldflags 注入 —— `nerdctl --version` 打印 `nerdctl version v2.4.1`。

## 与同链路分支的差异

| 项目 | 构建入口 | 备注 |
| --- | --- | --- |
| containerd | `make build && make binaries` | 需要 `osusergo netgo static_build` 之外的 tag，无 vendor |
| runc | `make` | 需要 libseccomp-dev，产物在仓库根 `./runc` |
| buildkit | 手写 `go build` | 上游 `make binaries` 走 docker buildx bake，托管 runner 用不了 |
| nerdctl | `make binaries` | 纯 Go（`CGO_ENABLED=0`），无 vendor，需联网拉 module |

nerdctl 不需要 Docker 也不需要 buildx，GitHub-hosted runner 上可以直接跑，这是四个
Go 项目里最省事的一条。

## 注意点

- **没有 `vendor/`**：v2.4.1 标签下不存在 vendor 目录（containerd 系其他仓库有），
  构建会走 `GOPROXY=https://proxy.golang.org`。不要照搬 buildkit 分支里
  `if [ -d vendor ]; then export GOFLAGS=-mod=vendor; fi` 的写法。
- **Go 版本下限**：`go.mod` 声明 `go 1.26.6`，脚本固定装 1.26.9（与 runc/buildkit 分支
  一致），并设 `GOTOOLCHAIN=auto` 兜底。
- **浅克隆下显式传 VERSION**：`VERSION ?= $(shell git describe --match 'v[0-9]*' ... || echo
  no_git_information)`。`--depth 1` 时 describe 依赖本地 tag ref，正常能出 `v2.4.1`，
  但一旦上游改成 annotated/lightweight 差异或 CI 换 clone 方式就会静默变成
  `no_git_information`，所以直接传参更稳。
- **`gomodjail:confined` 注释**：go.mod 顶部有 `//gomodjail:confined`，那只是给
  gomodjail 这个 lint 工具读的注释，普通 `go build` / `make binaries` 不受影响。
- **BUILDTAGS 可选**：上游 CI 额外跑一次 `BUILDTAGS=no_ipfs make binaries` 验证去掉 IPFS
  插件也能编译。默认（不带 tag）构建包含 IPFS 相关代码，依赖已在 go.mod 中，无需额外
  系统包。

## 依赖

`git make ca-certificates curl wget tar` + Go 1.26.9。没有 C 库依赖（libbtrfs、
libseccomp 等都不需要，nerdctl 只是 containerd 的 CLI 前端）。

## 验证

`_output/nerdctl --version`，另加 `file` 与 `ls -lh` 确认产物存在且是 ELF 可执行。
