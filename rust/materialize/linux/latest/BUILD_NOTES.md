# Materialize 流式数据库源码编译说明

上游仓库：<https://github.com/MaterializeInc/materialize>（Rust，流式 SQL 数据库，
"live data layer"，默认分支 main）

脚本：`get_materialize.sh`
分支：`rust/materialize/linux/latest`（本目录），对应 workflow `rust_materialize_linux_latest.yml`

## 官方构建命令

README/CONTRIBUTING 给的是标准 cargo 流程；workspace 的 `default-members`
以 `src/environmentd` 为核心（包名 `mz-environmentd`，产出二进制
`environmentd` 服务端，并连带编出 `clusterd` 计算进程）：

```
cargo build --release -p mz-environmentd
```

脚本用 `-p mz-environmentd` 限定默认成员闭包，与上游默认成员集一致，
避免编出 orchestratord/balancerd 等无关包，控制 4 核 runner 的编译量。

## 数据/事实（2026-10-27 实测）

| 事实 | 出处 |
|---|---|
| 构建入口是 cargo，workspace 含 `src/environmentd` | 根 `Cargo.toml` members/default-members |
| `[profile.release]` = `lto="thin"` + `debug=2`（全量调试信息） | 根 `Cargo.toml` 注释「Emit full debug info…core dumps」 |
| 仓库**没有** rust-toolchain 钉版文件，stable 即可 | 仓库根（rust-toolchain(.toml) 均不存在） |
| `mz-build-info` 会 `git describe` 嵌入版本号 → 必须**完整克隆**（非 shallow） | src/build-info 机制 |

## 与上游 profile 的差异（唯一一处）

上游 release profile 带 `debug=2`，4 核 runner 磁盘吃不下全量调试信息；
脚本用 cargo **官方 env 覆盖** `CARGO_PROFILE_RELEASE_DEBUG=0`（编译语义不变，
仅去掉 core dump 调试信息），其余参数完全按上游 profile。

## 硬门槛（任一不过就 FATAL）

- `cargo build --release -p mz-environmentd` 退出码 0；
- `target/release/` 产出 `environmentd`（必选）与 `clusterd`；
- 二进制逐个 `--version` 跑通（跑不通只 WARN，判据还是"能编译出 environmentd"）。

产物落到 `_materialize_build/artifacts/`（environmentd / clusterd / bins.txt /
revision.txt / cargo-build.log / sha256sums.txt），由 workflow 上传 artifact
`materialize-ubuntu-22.04`。workflow 另有磁盘清理（删 android/dotnet 等
预装软件包），thin-LTO 全量编译在 4 vCPU 上按 360 分钟上限兜底。
