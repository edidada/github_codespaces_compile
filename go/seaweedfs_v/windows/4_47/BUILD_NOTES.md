# go/seaweedfs_v/windows/4_47

此分支构建 seaweedfs_v。版本 4_47 对应官方稳定标签 4.47。

脚本只执行上游标准构建入口：go build ./weed。windows 由对应 GitHub-hosted runner 执行，避免跨平台交叉编译掩盖依赖问题。
