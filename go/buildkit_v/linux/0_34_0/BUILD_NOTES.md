# go/buildkit_v/linux/0_34_0

此分支构建 buildkit `v0.34.0` —— moby/buildkit 的最新稳定标签，containerd 生态里的镜像构建工具（`nerdctl build` 的后端）。

## 构建要点

- **没有走 `make binaries`**：v0.34.0 的 `Makefile` 里 `binaries: docker-buildx-build`，本质是 `docker buildx bake`，必须在有 Docker + buildx 的环境里跑，GitHub-hosted runner 上的 job 环境不满足（本仓库的其它分支已经反复验证过 k3s/moby 那类"构建器本身要 Docker"的项目在 hosted runner 上不可行）。因此脚本复刻 `Dockerfile` 中 `buildctl` / `buildkitd` 两个 build stage 的等价命令 —— 纯 `go build`，与 `docs/nydus.md` 里给的 `go build -tags=... -o ./bin/buildkitd ./cmd/buildkitd` 同型。
- 工具链：`go.mod` 声明 `go 1.26.8`（patch 级要求），脚本安装 go 1.26.9 满足；`GOTOOLCHAIN=auto` 作为兜底。
- 依赖：**零 C 库依赖**。仓库带 `vendor/`，v0.34.0 里 `seccomp` 构建标签对应的 vendored 实现（containerd/v2/pkg/seccomp 与 moby/profiles）都是纯 Go，不需要 `libseccomp-dev`；也不需要 pkg-config/btrfs/apparmor。脚本在有 `vendor/` 时显式 `-mod=vendor` 离线构建。
- 版本注入：上游靠 ldflags 写 `version.Version` / `version.Revision` / `version.Package`。这些变量在 Dockerfile 里来自 `ARGS VERSION=$(VERSION)` / `REVISION=$(GIT_COMMIT)`，而 `VERSION` 本身来自 `git describe`；浅克隆下为避免版本串跑偏，脚本直接显式传入 `v0.34.0` 与 HEAD sha。
- `CGO_ENABLED=0`：与上游 Dockerfile 一致；此时 `osusergo netgo static_build` 类标签多数不再生效但保留 `osusergo netgo seccomp` 以贴合上游 buildkitd stage（`static_build` 未使用，因为不需要静态产物）。
- 产物：`bin/buildctl`、`bin/buildkitd`（脚本末尾各自跑一次 `--version` 自检）。
- 未包含的可选标签：`nydus` / `nvidia.nvcci` / `gcp.sqlproxy` 等上游按 buildx target 组合的标签，本分支只构建默认形态。
