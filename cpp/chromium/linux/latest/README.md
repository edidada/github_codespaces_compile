# Chromium Linux latest

该分支在 GitHub-hosted Ubuntu runner 上构建 Chromium 的 `chrome` Release 目标。

- 使用 `gclient --no-history --shallow`，避免完整 Git 历史耗尽 runner 磁盘。
- 构建前清理与 Chromium 无关的预装 Android、.NET、GHC 和 CodeQL SDK。
- 关闭调试符号以降低构建输出体积，但仍完整编译 `chrome` 目标。
- CI 最后执行 `chrome --version` 验证产物，不启动需要图形会话的浏览器。
