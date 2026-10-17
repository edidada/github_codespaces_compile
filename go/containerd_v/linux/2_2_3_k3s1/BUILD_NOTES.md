# go/containerd_v/linux/2_2_3_k3s1

此分支构建 containerd 的 K3s 定制版本 `v2.2.3-k3s1`。

## 版本含义

- `2.2.3`：基于上游 containerd 官方 `v2.2.3`。
- `-k3s1`：K3s（Rancher/SUSE 维护的轻量级 Kubernetes 发行版）团队的打包标识，包含 k3s 专属补丁，**不是 containerd 官方发布的原版标签**。它由 `k3s-io/containerd` 分叉仓库维护，也是 K3s（如 `v1.36.1+k3s1`）内嵌的默认容器运行时；Go 模块依赖里指向该分叉时用的就是这个版本。

## 构建要点

- 源码取自 `https://github.com/k3s-io/containerd.git` 的 `v2.2.3-k3s1` 标签，模块路径仍是 `github.com/containerd/containerd/v2`，因此上游构建入口可直接复用。
- 只执行上游标准入口：`make build`（编译全部 Go 包）与 `make binaries`（产出 `bin/containerd`、`bin/ctr`、`bin/containerd-stress`、`bin/containerd-shim-runc-v2`），不做交叉编译，避免依赖问题被掩盖。
- 该 tag 的 `go.mod` 声明 `go 1.25.7`；脚本显式安装 containerd 自身 CI 使用的 `go 1.25.9`，不依赖 runner 预装的 Go 版本。
- `v2.2.3-k3s1` 在分叉仓库里是**轻量标签**而非 annotated tag，浅克隆下 `git describe --match 'v[0-9]*'` 取不到它（会退化成 commit sha），所以版本字符串通过 `VERSION=` 显式传给 make，保证 `bin/containerd --version` 报出 `v2.2.3-k3s1`。
- 默认构建不需要 protobuf/btrfs 开发包：`.proto` 生成代码已入库（`make protos` 仅用于校验），btrfs snapshotter 在 v2 里由 `btrfs` 构建标签控制，默认关闭。
- linux 腿由 GitHub-hosted ubuntu runner 执行。
