# go/juicefs_v/windows/1_4_1

此分支构建 juicefs_v。版本 1_4_1 对应官方稳定标签 v1.4.1。

脚本只执行上游标准构建入口：go build ./cmd/juicefs。windows 由对应 GitHub-hosted runner 执行，避免跨平台交叉编译掩盖依赖问题。
