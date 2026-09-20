# rust/ripgrep_v/macos/15_2_0

此分支构建 ripgrep_v。版本 15_2_0 对应官方稳定标签 15.2.0。

脚本只执行上游标准构建入口：cargo build --release。macos 由对应 GitHub-hosted runner 执行，避免跨平台交叉编译掩盖依赖问题。
