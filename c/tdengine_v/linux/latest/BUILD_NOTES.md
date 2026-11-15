# TDengine 时序数据据库源码编译说明

上游仓库：<https://github.com/taosdata/TDengine>（C 语言，时序数据库）

脚本：`get_tdengine.sh`
分支：`c/tdengine_v/linux/latest`（本目录），对应 workflow `c_tdengine_v_linux_latest.yml`

## 为什么是纯 cmake 路线

官方 README 与 docs 给的就是标准 CMake 流程（Ubuntu）：

```
mkdir debug && cd debug
cmake .. && cmake --build .
```

本脚本把 `mkdir` 换成 `_tdengine_build/build`，构建类型用 Release，
并额外传 `-DBUILD_TOOLS=true`（官方支持的可选开关，把 taosBenchmark 一起编出来）；
若上游把开关改名导致配置失败，脚本回落到 README 默认参数再配一次（只 WARN，不硬挂）。

## 数据/事实

| 事实 | 出处 |
|---|---|
| 构建入口就是 CMake | README（docs.taosdata.com/quickstart） |
| 产物在构建目录 `bin/` 下：`taosd`（服务端）、`taos`（CLI） | README |
| TDengine 3.x 需要 CMake ≥ 3.10 / gcc；runner 自带 | 根目录 CMakeLists / README |
| 依赖的第三方库都在仓库内 `deps/`，构建不需要额外网络包 | 仓库结构 |

## 硬门槛（任一不过就 FATAL）

- `cmake --build .` 退出码 0；
- 构建目录里产出可执行的 `taosd`（必选）与 `taos`（如有则一并校验）；
- 逐个二进制跑 `-V`（跑不通只 WARN，判据还是"能编译出 taosd"）。

产物落到 `_tdengine_build/artifacts/`（taosd / taos / bin-list.txt / revision.txt /
build.log / sha256sums.txt），由 workflow 上传 artifact `tdengine-ubuntu-22.04`。
