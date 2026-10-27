# Newlib 裸机 C 库源码编译说明

上游：<https://sourceware.org/newlib>（sourceware.org/git/newlib-cygwin，C，
嵌入式/裸机标准 C 库，eCos/cygwin 系老牌 libc）

脚本：`get_newlib.sh`
分支：`c/newlib_v/linux/latest`（本目录），对应 workflow `c_newlib_v_linux_latest.yml`

## 官方构建方式

git 化仓库（newlib-cygwin）含 cygwin 等大块头，且 master 分支需要自持
autoconf 生成 configure；**官方发布 tarball**（sourceware.org/pub/newlib）
自带已生成的 configure，是官方文档推荐的稳定源码形态。脚本拉取当前最新
发布 **newlib-4.6.0.20260123**（2026-01-23 发布）：

```
../configure --target=arm-none-eabi --prefix=... --disable-multilib
make -jN && make install
```

交叉工具链用 apt 的 `gcc-arm-none-eabi`（含 binutils）——编译目标是
真正的裸机（system=none / arm-none-eabi），产物 libc.a/libm.a 只能链接进
ARM firmware，不是给 Linux 宿主程序用的。

## 数据/事实

| 事实 | 出处 |
|---|---|
| 最新发布 4.6.0.20260123（2026-01-23） | sourceware.org/pub/newlib/ 发布列表第一项 |
| target 版交叉构建流程就是 configure --target + make install | newlib README（How to configure and build newlib） |
| 发布 tarball 自带 configure（免 autoconf） | tarball 内容 |
| --disable-multilib 只编默认 ARM 变体，规避 apt gcc 各 multilib 差异 | 常规 cross-build 实践 |

## 硬门槛（任一不过就 FATAL）

- configure / make / make install 退出码均 0；
- prefix 中产出 `libc.a` 与 `libm.a`；
- `arm-none-eabi-ar t libc.a` 成员数 ≥ 50；
- `arm-none-eabi-nm libc.a` 里找得到 `printf` 符号（证明是真 libc 而非空壳）。

产物落到 `_newlib_build/artifacts/`（libc.a + libm.a +
newlib-arm-none-eabi-prefix.tar.gz = 完整 sysroot（含 include/）+ toolchain.txt +
revision.txt + make.log + sha256sums.txt），由 workflow 上传 artifact
`newlib-ubuntu-22.04`。
