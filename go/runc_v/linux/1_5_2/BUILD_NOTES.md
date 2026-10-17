# go/runc_v/linux/1_5_2

此分支构建 runc `v1.5.2` —— opencontainers/runc 的最新稳定标签（1.6.0 截至创建本分支时仍停在 `v1.6.0-rc.1`）。runc 是 containerd 的默认 low-level runtime，与 `go/containerd_v/linux/2_2_3_k3s1` 分支构成同一条运行时链路。

## 构建要点

- 上游入口：v1.5.2 的 Makefile 默认目标就是 `runc`（`.DEFAULT: runc` → `runc-bin` → `go build -o runc .`，动态 PIE），**产物在仓库根 `./runc`，不是 `bin/runc`**。这个 tag 里没有 `local`，也没有 `binaries` 目标（只有 `test-binaries` 产出测试辅助二进制）；`make static` 走 `-static-pie + netgo osusergo`，留给 release 流程（`script/release_build.sh` = `make static EXTRA_FLAGS="-a"`）。
- 构建标签：默认 `BUILDTAGS := seccomp urfave_cli_no_docs libpathrs`，其中 `libpathrs` 需要 Rust 的 libpathrs 库（`#cgo pkg-config: pathrs`，apt 没有现成包）。**上游自己的 CI 就用 `RUNC_BUILDTAGS=-libpathrs` 去掉它**（`.github/workflows/test.yml`），所以本分支照此办理，不算魔改；`seccomp` 标签保留，ubuntu-24.04 的 libseccomp 2.5.5 满足要求。
- 依赖（README 的 Linux 一节）：`make gcc linux-libc-dev libseccomp-dev pkg-config git`。`libgpgme` 只在 release 签名时用到，构建不需要。仓库自带 `vendor/`，`go.mod` 对 containerd 没有本地 `replace`，所以不需要旁边再放 containerd 源码。
- Go 版本：`go.mod` 声明 `go 1.25.0`，上游 CI 跑 1.26.x / 1.27.x，脚本固定安装 1.26.9，不依赖 runner 预装版本。
- 版本信息：Makefile 用 `COMMIT := $(shell git describe --dirty --long --always)` 注入 `-X main.gitCommit`，`runc --version` 的版本号来自 Go build info（模块版本），因此脚本在构建前断言 describe 结果以 `v1.5.2` 开头。踩过的坑：断言不能写成 `test -f .git/refs/tags/<tag>`，浅克隆会把 tag 写进 `packed-refs`，文件并不存在。
- 未跑测试：`make test` / `localunittest` / `localintegration` 都不在本分支范围内（本仓库只做"从源码编译"）。
