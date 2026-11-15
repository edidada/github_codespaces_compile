# AGENTS.md — github_codespaces_compile 仓库说明

给 AI 工具（Claude Code、Codex、Cursor、CodeBuddy 等）阅读的仓库约定。动手前先读本文件。

## 1. 仓库定位

本仓库是**私有构建脚本仓库**，存放各类软件的实际源码编译 / 打包脚本（`get_xxx.sh`、
`build_xxx.sh`、`build.sh` 等）。它本身不跑 CI 触发，而是被 `compiler_script` 仓库的
GitHub Actions workflow 克隆并执行。

配套仓库：`edidada/compiler_script`（本地路径 `d:/develops/git/github/compiler_script`），
通过 Actions secret `COMPILER_PAT` 以 `gh repo clone ... --single-branch --branch '<branch>'` 拉取。
两个仓库**成对使用**：branch 名相同、workflow 与脚本目录一一对应。

```
compiler_script/.github/workflows/cpp_chromium_linux_latest.yml
        │  clone --branch cpp/chromium/linux/latest
        ▼
github_codespaces_compile/cpp/chromium/linux/latest/get_chromium.sh   ← 真正干活的脚本
```

## 2. 分支规划

### 命名规范

```
编程语言/软件名称/操作系统/版本
例：cpp/chromium/linux/latest      rust/rust/linux/1_91_0
    java/openjdk/linux/25          android/aosp_v/linux/android17_release
```

- 脚本目录路径与分支名一致：分支 `cpp/chromium/linux/latest` → 目录
  `cpp/chromium/linux/latest/get_chromium.sh`。
- 顶层按语言分目录：`c` `cpp` `java` `python` `go` `rust` `ruby` `erlang` `lua` `csharp` `scala`
  `kotlin` `zig` `ts` `javascript` `actionscript` `as` `android` `shell` `dockerfile` `web` 等，
  另有 `tools/`（公共工具）、`files/`、`catalogs/`。
- **一分支一软件一脚本**：分支只承载自己的脚本目录（+ 可选 `README.md`、`.gitattributes`）。
- `latest` 分支 = 滚动跟踪上游最新；`x_y_z` 版本分支 = **固定版本存档**。
  升级 latest 里的版本号前，先 `checkout -b` 出旧版本号分支存档（内容不变），再改 latest，
  不要原地直接改。存档分支的脚本路径仍留在 `.../latest/`，这是设计，不要搬路径。

### 脚本约定

- Shebang `#!/usr/bin/env bash`（或 `#!/bin/bash`），首部 `set -euo pipefail`。
- 脚本要幂等、可重复执行；不写死绝对路径，用 `$(pwd)`/`$RUNNER_TEMP`/参数。
- 产物放到 `source/_<name>_build/artifacts/`（相对 workflow 的 working-directory `source`），
  供 `actions/upload-artifact@v4` 上传；同时写 `build-info.txt`（项目、commit、OS、arch）。
  **注意**：脚本里若 `cd` 到别处，先用 `TOP_DIR="$(pwd)"` 保存起始目录再拼产物路径。
- 编译主命令用 `set +e` 包裹并把日志落文件，失败时 `tail` 日志后 `exit` 非 0
  （避免"编译挂了但脚本返回 0"的假绿）。
- **`.sh` 必须用 LF**：分支内放 `.gitattributes` 写 `*.sh text eol=lf`，
  否则 Windows runner 的 `core.autocrlf=true` 会转成 CRLF 让 bash 报 `\r` 错。
- 变量引用统一 `${VAR}`（macOS bash 3.2 会把 `$VAR中文` 的全角字符吞进变量名）；
  不用 `chmod +x --`（BSD chmod 不认 `--`）；不用 BSD/GNU 不兼容的 `sed -i` 裸写法。

### main 的角色

`main` 是**聚合分支**：所有"真正干活的"分支最终都 merge 到本地 main，汇总全部脚本
（当前 1767 个文件）。本地合并用 `git merge --no-edit -X ours <branch>`；
独立根/orphan 分支（如 `cpp/oceanbase/linux/latest`）用 `--allow-unrelated-histories` 单独并。
`main` 自身不承载任何分支的构建任务，历史里被规范化的旧式脚本不要捞回来。
另有 `.gitmodules` 把 `compiler_script` 登记为 submodule（历史遗留）。

## 3. GitHub Actions OS 列表

脚本被 workflow 调度，必须按目标 runner 的 OS / 架构写依赖与分支。

### runner 标签 → 实际镜像（实测，wiseism 账户 2026-11）

| 标签 | 实际镜像 | 架构 | 备注 |
|---|---|---|---|
| `ubuntu-latest` | ubuntu-26.04 | x86_64 | GCC 15 / CMake 4.4.5；4 vCPU / 16 GB / 14 GB SSD |
| `ubuntu-22.04` | ubuntu-22.04 | x86_64 | jammy，WebKitGTK 4.0、libsoup 2.4 |
| `ubuntu-24.04` | ubuntu-24.04 | x86_64 | noble，WebKitGTK 4.1、libsoup 3.0 |
| `ubuntu-26.04` | ubuntu-26.04 | x86_64 | 显式 pin；默认 `-std=gnu23`，K&R/隐式声明会报错 |
| `ubuntu-24.04-arm` / `ubuntu-22.04-arm` | arm64 变体 | aarch64 | Azure Cobalt 100；**必须显式写 `-arm` 标签** |
| `windows-latest` | windows-2025-vs2026 | x86_64 | VS 18 / MSVC 19.51；默认 shell pwsh，Git Bash 可用 |
| `windows-2022` | windows-2022 | x86_64 | VS 2022 / MSVC 19.4x |
| `macos-latest` | macos-26-arm64 | arm64 | Apple Silicon；自带 bash 3.2、`iconutil`/`actool`/`hdiutil` |
| `macos-14` | macOS 14 | arm64 | `macos-14 + arm64` 组合不被支持 |
| `macos-12` | 已退役 | — | 排队 24h 后超时，禁止使用 |
| `[self-hosted, aosp]` | 自托管 | — | AOSP 等超大型构建（源码 ~250 GB，托管 runner 装不下） |

### 多 OS / 多 CPU 矩阵约定

- 标准 6 腿矩阵：`ubuntu-22.04` / `ubuntu-24.04` / `ubuntu-26.04` / `ubuntu-24.04-arm` /
  `windows-latest` / `macos-latest`，覆盖 x86_64 与 arm64 双架构。
- **runner 标签决定真实机器架构**，matrix 里自定义 `arch` 变量只是标注字符串，不改变架构；
  实测 macos-latest 上写 `arch: x86_64` 得到的仍是 arm64。
- 脚本用 `uname -s` / `uname -m` 分支处理 OS 差异，不要假设只在 Linux 跑。
  - Linux：GTK3/WebKitGTK（`libgtk-3-dev libwebkit2gtk-4.1-dev libsoup-3.0-dev`，22.04 回退 4.0/2.4）。
  - Windows：`CGO_ENABLED=0`（Go）、MSVC、`-H windowsgui`；WebView2 由 runner 自带。
  - macOS：WKWebView、cgo + Xcode clang；GNU 工具缺失（BSD sed/chmod/bash 3.2）。
- x86_64 与 arm64 的构建缓存/预编译产物不可跨架构复用；NASM 汇编仅 x86_64。

### 已知踩坑（按 OS）

- Ubuntu 26.04 GCC 15 / C23 严格指针检查：K&R 代码、`strchr` 返回值需 `(char *)` 强转，
  去掉 `-Werror`（OceanBase 实测）。
- 自带工具链链接 `libssl.so.1.1`（OpenSSL 1.1）而 Ubuntu 26.04 只有 OpenSSL 3 →
  从 Ubuntu focal 解出 `libssl1.1` 设 `LD_LIBRARY_PATH`，或把 devtools 的 cmake 换成系统 cmake wrapper。
- GCC 16 移除 `libmpx`，configure 带 `--enable-libmpx` 会报 unrecognized option。
- CPython 3.15 无 `--without-tests` 选项；Python 2.7 的 `python2.7` 命令要随版本改成 `python3.15`。
- CMake 4.x 对 `file(COPY <不存在的目录>)` 直接报错（3.x 只是警告）→ 补空目录占位。
- 托管 runner 资源上限：4 核 / 16 GB / 14 GB(根盘约 84 GB) / 6h。
  超重型构建要清 `/usr/share/dotnet`、`/usr/local/lib/android` 等 SDK 腾磁盘，
  补 swap（`fallocate` + `mkswap` + `swapon`），并行度按内存算（约 5 GB/job），日志写持久路径别写 `/tmp`(tmpfs)。

数据来源：`ai_agent_scripts/git/github/github_action.txt`（runner OS/CPU 实测笔记）与
`compiler_script` 仓库 workflow。

## 4. 提交与验证流程

1. 与 `compiler_script` **成对**各 `checkout -b <同名分支>`；本仓库加脚本目录
   （`get_xxx.sh` + `.gitattributes`）。
2. `bash -n` 校验脚本后 commit；workflow 侧同步加 YAML + README 行。
3. **先推本仓库分支，再推 compiler_script 分支**（后者 push 触发 Actions，会 clone 本分支）。
4. 用 `gh run list / watch / view <id> --log-failed` 盯日志；失败按日志修脚本、重推迭代，
   直到**全部 job 成功**且 artifact 有真实产物（不能以部分成功收尾）。
5. 成功后两仓库分支各自 merge 到本地 `main`（见 §2），最后 `git push origin main`
   （仅限 origin，其它 mirror remote 需另行确认）。
