# picolibc 裸机 C 库源码编译说明

上游：<https://github.com/picolibc/picolibc>（C，newlib 系现代裸机标准 C 库，
Keith Packard 维护，原生 meson 构建）

脚本：`get_picolibc.sh`
分支：`c/picolibc_v/linux/latest`（本目录），对应 workflow `c_picolibc_v_linux_latest.yml`

## 官方构建方式

上游自带 `scripts/do-arm-configure` ≡ `do-configure arm-none-eabi`：
内部 `meson setup --cross-file scripts/cross-arm-none-eabi.txt`（该 cross-file
设 `skip_sanity_check=true`，因为 exe_wrapper `run-arm` 在 CI 上不可用），
在当前目录建 build 目录、源码目录取 `scripts/..`。本仓库脚本做法：

```
mkdir build && cd build
../picolibc/scripts/do-arm-configure \
    -Dtests=false -Dtests-cdefs=false -Dwerror=false -Ddebug=false \
    -Dprefix=<artifacts>/prefix
ninja && meson install
```

- 上游 CI（.github/do-run）也是 `scripts/do-<target>-configure -Dwerror=true -Ddebug=false`；
  本脚本把 werror 关掉以规避 apt 交叉 gcc 版本差异的告警漂移。
- `do-arm-configure` 默认带 `-Dtests=true`，此处追加 `-Dtests=false` 覆盖
  （测试需要 qemu + semihosting 才能运行，只编库不需要）。
- 交叉工具链用 apt 的 `gcc-arm-none-eabi`（真裸机 arm-none-eabi 目标）；
  meson/ninja 用 pip 最新版（上游要求 meson ≥ 0.61，ubuntu-22.04 apt 版本太老）。

## 数据/事实

| 事实 | 出处 |
|---|---|
| `scripts/do-arm-configure` = `exec do-configure arm-none-eabi -Dtests=true "$@"` | 仓库 scripts/do-arm-configure 第 36 行 |
| cross-file `scripts/cross-arm-none-eabi.txt`，编译器就是 arm-none-eabi-gcc/-g++ | 仓库 scripts/cross-arm-none-eabi.txt |
| `skip_sanity_check = true`（exe_wrapper 不存在也能配置） | 同上 [properties] 段 |
| build 目录 = meson setup 运行时的 cwd，源码 = scripts/.. | scripts/do-configure |
| 上游 CI 配置传 `-Dwerror=true -Ddebug=false` | .github/do-run |
| meson 最低版本 0.61 | 上游文档/版本文案 |

## 硬门槛（任一不过就 FATAL）

- meson setup / ninja / meson install 退出码均 0；
- prefix 中产出 `libc.a`、`libm.a`、`stdlib.h`（保真：find 有且非空）；
- `arm-none-eabi-ar t libc.a` 成员数 ≥ 50；
- `arm-none-eabi-nm libc.a` 里找得到 `printf` 符号；
- `.specs` 文件存在则记 PASS，没有只 WARN（版本行为差异，不硬卡）。

产物落到 `_picolibc_build/artifacts/`（libc.a + libm.a +
picolibc-arm-none-eabi-prefix.tar.gz = 完整 install 树（含 include/）+
toolchain.txt + revision.txt + ninja.log + sha256sums.txt），由 workflow
上传 artifact `picolibc-ubuntu-22.04`。
