# cpp/pistache_v/linux/0_4_25

此分支构建 pistache_v。版本 0_4_25 对应截至 2026 年仍维护的官方稳定标签 v0.4.25。

Pistache 和 sRPC 均以 Linux 作为其主要受支持的部署目标；因此只创建 Linux 任务，避免将未验证的 macOS/Windows 构建伪装为可支持的平台。脚本使用上游 CMake 的 out-of-source Release 构建；sRPC 检出子模块以取得构建所需的上游依赖。
