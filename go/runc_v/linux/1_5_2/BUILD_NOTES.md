# go/runc_v/linux/1_5_2

此分支构建 runc `v1.5.2` —— opencontainers/runc 的最新稳定标签（1.6.0 截至创建本分支时仍停在 `v1.6.0-rc.1`）。runc 是 containerd 的默认 low-level runtime，与 `go/containerd_v/linux/2_2_3_k3s1` 分支构成同一条运行时链路。

## 构建要点

- 上游标准入口是 `make local`（`bin/runc`，动态链接、带 libseccomp 支持）。**没有跑默认的 `make`（= verify + local）**：`verify` 第一步 `script/git-check` 要求容器环境里的 git 鉴权，并且会去校验 `go mod vendor` 提交，裸 runner 上会误报；这一条与上游自己 `.github/workflows/runc.yml` 的区分一致——裸 runner 作业用 `make local`，容器作业才用 `make`。
- 依赖（ubuntu-24.04）：`git gcc libc6-dev libseccomp-dev pkg-config`。`libseccomp-dev` 是硬依赖，Makefile 会 `test -e /usr/include/seccomp.h`；ubuntu-24.04 自带 libseccomp 2.5.5，满足 `check-seccomp` 要求的 >= 2.5.1，因此 seccomp 支持默认开启。
- Go 版本：`go.mod` 声明 `go >= 1.24.0`，上游 CI 用 1.24.10 / 1.25.9，脚本固定安装 1.25.9，不依赖 runner 预装版本。
- `GOPROXY=https://proxy.golang.org,dynamic`：runc 对 containerd 的 replace 是远端 pseudo-version，**独立克隆场景不需要本地 containerd 源码**（本地实测 `replace => ../containerd` 的写法会因 refspec 失败）。仅当按上游文档把 runc 放进 `src/github.com/opencontainers/runc` 布局、想让 replace 生效时才需要 `SKIP_VALIDATE=1`。
- 版本号来源是 `git describe --match 'v[0-9]*'`（需要 annotated tag 对象），因此采用有限深度克隆，并在构建前断言 `refs/tags/v1.5.2` 存在且 describe 结果正确；`VERSION`/`COMMIT` 通过 ldflags 注入 `internal/version`，产物里 `config` 的 build tag 列表（seccomp/apparmor）来自 `go build -tag`，不是 ldflags。
- 产物：`bin/runc`（本分支只构建这一个二进制，未跑 `make cross` 的 13 个平台交叉产物）。
- linux 腿由 GitHub-hosted ubuntu runner 执行，未做交叉编译。
