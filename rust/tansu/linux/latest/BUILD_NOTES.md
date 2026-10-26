# Tansu（已更名 Nisshi）Kafka 兼容 broker 源码编译说明

上游仓库：<https://github.com/tansu-io/tansu>。工作区已按上游口径改名为 **nisshi**
（Cargo.toml：repository = <https://github.com/nisshi-io/nisshi>，homepage = <https://nisshi.io>），
但 tansu-io/tansu 这个 URL 仍在（GitHub 重定向可用），所以流程名保持用户口径 `rust/tansu/linux/latest`。

脚本：`build.sh`，主命令 `cargo build --release`（没有 Makefile/Bazel，cargo 就是官方构建入口）。
产物是单个静态二进制：`target/release/nisshi`（改名前的旧名 `tansu` 也做兜底校验），
内含 broker / topic / cat / proxy 子命令。

## 目录/语言/动机

- 语言：纯 Rust（edition = 2024，需要较新的 stable 工具链，runner 自带的即可）。
- 定位：无状态（stateless）Kafka 协议兼容 broker，存储可插拔：
  PostgreSQL / libSQL（SQLite）/ S3 / 内存；
  schema 校验支持 Avro / JSON / Protobuf；可落 Apache Iceberg / Delta Lake。
- 与 Redpanda 对比：Redpanda 是 C++ 写的高兼容完整 broker；Tansu/Nisshi 砍掉了
  复制与领导者选举，换取轻量运维。

## 已知依赖要点

- edition 2024：Rust 版本按 ubuntu runner 自带 stable（≥1.85 均可），脚本会打印版本入日志。
- 工作区成员含 fuzz / smoke-test 等，`cargo build --release` 默认全 workspace 编译；
  若上游某成员新增 issue，另一条腿 `rust/tansu/linux/<ver>` 可固定 tag 验证旧版。

硬门槛：`cargo build --release` 退出码 0，且 `target/release/nisshi`（或 tansu）存在并可执行。
