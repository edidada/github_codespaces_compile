# cpp/srpc_v/linux/latest

此分支构建 srpc_v。版本 latest 表示上游默认主分支。

Pistache 和 sRPC 均以 Linux 作为其主要受支持的部署目标；因此只创建 Linux 任务，避免将未验证的 macOS/Windows 构建伪装为可支持的平台。脚本使用上游 CMake 的 out-of-source Release 构建；sRPC 检出子模块以取得构建所需的上游依赖。
