# k3s v1.37.1+k3s1（Linux，无 Docker 构建路径）

## 版本

`v1.37.1+k3s1` 是 k3s-io/k3s 当前最新稳定标签（`git ls-remote --tags` 里 v1.37.1 系列只有
`v1.37.1+k3s1` 和两个 `v1.37.1-rcN+k3s1`；rc 不算稳定版）。它的 `go.mod` 里
`github.com/containerd/containerd/v2 => github.com/k3s-io/containerd/v2 v2.3.4-k3s1`、
`github.com/opencontainers/runc => v1.4.2`，也就是说 k3s 内嵌的正是
`go/containerd_v/linux/2_2_3_k3s1` 那条分支所在的 k3s 定制 containerd 系列（版本号
命名不同：模块走 v2.3.4-k3s1 tag），两个分支构成上下游关系。

## 为什么不能照别的项目那样直接 make

上游 `Makefile` 的 `binary` / `ci` 目标全是：

```make
binary:
	docker buildx build --build-arg GIT_TAG=... -f Dockerfile --target=result --output=. .
```

Dockerfile 的 `infra` stage 是 `golang:1.26.8-alpine3.24` + `tonistiigi/xx:1.6.1`，
用 `xx-_apk`（musl + `libseccomp-static`/`sqlite-static`/`libselinux` 等）做
**静态交叉编译**，`TARGETOS/TARGETARCH` 由 buildx 注入。GitHub-hosted runner 上
docker/buildx 不可用（containerd、buildkit 两条分支已经验证过：cgroup v2 下
`--privileged` 容器起不来，`failed to create cgroup "/inotify": Permission denied`），
`make binary` 必然失败。

所以本脚本走"复刻 stage 命令"的路子（和 `go/buildkit_v` 同一手法）：按 Dockerfile
里 `manifests → build → package-cli` 三个 stage 的顺序，直接在宿主上跑它们调用的脚本。

## 三个脚本各自做什么

| 脚本 | 内容 |
| --- | --- |
| `scripts/download` | 按 `scripts/version.sh` 推导的版本，把 runc 源码 clone 到 `build/src/github.com/opencontainers/runc`、k3s 版 containerd clone 到 `build/src/github.com/containerd/containerd`；下载并校验（sha256）`k3s-root-${ARCH}.tar` 解开；用 `yq` 解析 `manifests/` 里的 HelmChart CRD，从 k3s.io 抓 chart 到 `build/static/charts` |
| `scripts/build` | 先 GOPATH 模式（`GO111MODULE=off`）编 CNI 插件（rancher/plugins + flannel cni-plugin），再 `CGO_ENABLED=1 go build ./cmd/server` 出 `bin/k3s`，把它 symlink 成 kubectl/containerd/crictl/ctr/k3s-* 等；然后在刚 clone 的 containerd 源码里编 `containerd-shim-runc-v2`，在 runc 源码里 `make` 出 `runc`，一起拷进 `bin/` |
| `scripts/package-cli` | 把 `bin/` + `etc/` 打包成 `build/out/data-linux-amd64.tar.zst`（`tar --sort=name --mtime=@0` + `zstd --long=25`，可复现），按内容 hash 放进 `build/data/<hash>.tar.zst`，再 `CGO_ENABLED=0 go build ./cmd/k3s` 出 `dist/artifacts/k3s`（带内嵌数据的包装器）。结尾调 `scripts/build-upload`，该脚本在 `AWS_SECRET_ACCESS_KEY` 为空时直接 `exit 0`，所以不会去传 S3 |

## 环境变量（对齐上游 Dockerfile 的 ARG/ENV）

- `GIT_TAG=v1.37.1+k3s1`：`scripts/version.sh` 会校验它必须匹配
  `$VERSION_K8S[+-]` 前缀（也就是 `v1.37.1+`），不匹配立刻 `exit 1`；
  `scripts/git_version.sh` 里的 `git tag -l --contains HEAD` 在浅克隆下不稳，所以显式传。
- `TARGETOS=linux`、`TARGETARCH=amd64`：`scripts/platform.sh` 据此设 `OS/ARCH/GOOS/GOARCH`
  以及 `BIN_SUFFIX`（amd64 时为空，产物名就是 `dist/artifacts/k3s`）。
- `SELINUX=true`：跟 infra stage 默认一致，给 k3s / runc 的 build tag 加 `selinux`，
  因此需要 `libselinux-dev`。
- **`STATIC_BUILD` 不设**（上游是 `true`）：这是本分支唯一的实质差异。上游靠 alpine
  的 `musl-dev`/`libseccomp-static`/`sqlite-static` 做 `-extldflags '-static'`，
  Ubuntu/glibc 上没有对应的静态包，硬开只会链接失败。代价是产物动态链接 glibc，
  不能像官方发行版那样丢到任意发行版上跑；tag 组合、ldflags 注入的版本信息都不变。

## 依赖

apt：`build-essential git make curl ca-certificates zstd pkg-config libseccomp-dev
libapparmor-dev libselinux-dev xz-utils`（对应 infra stage 的 `alpine-sdk`、
`gcc musl-dev linux-headers zlib-dev libseccomp-dev libselinux-dev` 等；
`zstd` 对应 apk 的 `zstd`，`package-cli` 打 data tarball 要用）。
Go：`1.26.8`（= 上游 `GOLANG` ARG 的版本，`go.mod` 里 `go 1.26.8`）。
yq：mikefarah Go 版 `v4.44.3` 装到 `/usr/local/bin` —— `scripts/download` 用的是
`yq eval --no-doc .spec.chart` 这种 mikefarah 语法，apt 里的 Python 版 `yq` 不认，
脚本会先 `yq --version | grep mikefarah` 检测再决定装不装。

## 没做的事

- 不打容器镜像（`scripts/package-image` 要 docker）、不做 airgap 包、不跑
  `scripts/binary_size_check.sh`（那是上游对静态包体积的门禁，动态链接产物套不上它的阈值）。
- 不做多架构（`multiarch-binary` 依赖 buildx + xx 交叉）。

## 验证

`bin/k3s --version`（真正的 server 二进制，输出 `k3s version v1.37.1+k3s1`）、
`dist/artifacts/k3s --version`（内嵌数据包装器，失败只 WARN 不阻塞）、
外加 `ls -lh bin/ dist/artifacts/` 与 `file bin/k3s`。
