# SeaBIOS 编译说明（c/seabios_v/linux）

上游：<https://github.com/coreboot/seabios>（coreboot 项目的 GitHub 镜像，权威仓库在
<https://review.coreboot.org/seabios>）。SeaBIOS 是 x86 的 legacy BIOS 实现，产物是
ROM 镜像而不是能装进操作系统的程序，所以"跑起来"的验证方式和一般 C 项目不同：判据落在
镜像本身（尺寸合法 + 版本串 + ELF/option-ROM 头部自洽），qemu 启动只作为附加证据。

## 支持的 OS：只有 Linux/x86

这不是"先铺 Linux 以后再补"，而是上游构建体系决定的上限。证据全部对着 Makefile：

| 约束 | 出处（master 行号） | 为什么 macOS / Windows 不行 |
| --- | --- | --- |
| `-m32 -march=i386 -mregparm=3` | `Makefile:60-66` COMMONCFLAGS | 需要 gcc 的 x86 32 位后端；当前 GitHub `macos-*` runner 是 arm64（Apple Silicon），连 `-m32` 的目标架构都不对 |
| `LD32BIT_FLAG:=-melf_i386` | `Makefile:27` | 只有 GNU ld 的 ELF `elf_i386` 目标提供；`windows-*` runner 上能拿到的 MSVC `link.exe` / MinGW 默认是 PE/COFF |
| `objdump -thr` + `scripts/layoutrom.py` 生成三个链接脚本 | `Makefile:172-175` | 段布局是从 **ELF** section 表反推出来的，换 COFF 直接没有输入 |
| "implements an X86 legacy bios that is built with standard GNU tools" | `README:1-2` | 上游自己的定位 |

因此 runner 矩阵只铺 `ubuntu-22.04 / ubuntu-24.04 / ubuntu-26.04`（x86_64）。

## OS 版本覆盖

SeaBIOS 的构建依赖极少：`gcc`（≥4.4）、GNU `binutils`、`python3`、coreutils。真正的
环境门槛由上游自带的 `scripts/test-build.sh` 在每次 `make` 前自检（`Makefile:113-116`，
返回 `-1` 就 `$(error "Please upgrade the build environment")`），脚本第 3 步把它单独跑
一遍，好让失败落在明确的步骤里。三个 Ubuntu 版本的 gcc 分别是 11 / 13 / 更新的发行版
版本，都在上游支持范围内。

## 版本覆盖

`latest` 自动取上游最新的正式 `rel-*` tag（`git tag --list 'rel-*'` 过滤掉带 `rc`/`pre`
后缀的，再 `sort -V` 取最大）；固定版本分支把 `SEABIOS_TAG` 写死成 `rel-x.y.z`。

每个版本都编四种 Kconfig 目标，产物分别是：

| 配置 | 关键开关 | 产物 | 用途 |
| --- | --- | --- | --- |
| `QEMU` | `CONFIG_QEMU=y`（`src/Kconfig:9-17` 的 choice 默认值） | `out/bios.bin` | QEMU / KVM / Xen / Bochs 的 `-bios` |
| `COREBOOT` | `CONFIG_COREBOOT=y` | `out/bios.bin.elf` | coreboot 的 fallback payload |
| `CSM` | `CONFIG_CSM=y` | `out/Csm16.bin` | EFI 固件里的 Compatibility Support Module |
| `VGA` | `CONFIG_QEMU=y` + `CONFIG_VGA_BOCHS=y` | `out/bios.bin`、`out/vgabios.bin` | 独立 option ROM（seavgabios 那条路线） |

`target-y` 由 `.config` 里的这些开关直接决定（`Makefile:97-101`），所以脚本除了正向断言
产物存在，还**反向断言不属于本目标的产物不许出现**——否则很容易出现"四次都在编同一个
QEMU 目标"的假通过。

## 两个必踩的坑

1. **`PYTHON=python`**：`Makefile:25` 写死了 `python`，Ubuntu runner 上只有 `python3`。
   每条 make 都要带 `PYTHON=python3`，否则 `buildversion.py` / `layoutrom.py` 起不来。
2. **Kconfig 是 choice**：只往 `.config` 里塞一行 `CONFIG_CSM=y` 不够，必须
   `make olddefconfig`（`Makefile:263-264` 的 `%onfig:` 规则）让 choice 真的切换，
   然后再断言 `.config` 里那一行仍然是 `y`。

另外 `git clone` 不能用 `--depth`：`scripts/buildversion.py:39` 用
`git describe --always --tags --long --dirty` 取版本串，浅克隆拿不到 tag 会让版本串退化成
`"?"`，产物里就认不出这是哪个 SeaBIOS 了。

## qemu 启动验证为什么只 WARN

runner 上没有 `/dev/kvm`，只能跑 TCG；镜像里也没有可引导设备，SeaBIOS 打完 banner 就停在
"no bootable device"，最后靠 `timeout` 收场（退出码 124）。这些都和"代码能不能编、镜像是否
合法"无关，所以它只作为额外证据，不作为失败条件。

---

## 本分支：`rel-1.16.0`

目录 `c/seabios_v/linux/1_16_0` 固定编译 tag `rel-1.16.0`，构建步骤、四种 Kconfig 目标与产物判据和 `latest` 完全一致（脚本只改 `SEABIOS_TAG` 一行）。

## 铺不了的老版本：rel-1.13.0 及更早（2026-10-26 CI 实测）

一开始按"版本尽量全"铺了 1.13.0 / 1.11.2 / 1.9.3 三条，三条在**三个 runner 上全红**，
原因是上游构建流程和现代 binutils 冲突，不是脚本写错。已删掉这三条分支，证据留在这里。

当前 GitHub Ubuntu 镜像的工具链（同一次运行里打印的）：

| runner | gcc | GNU ld |
| --- | --- | --- |
| ubuntu-22.04 | 11.4.0 | 2.38 |
| ubuntu-24.04 | 13.3.0 | 2.42 |
| ubuntu-26.04 | 15.2.0 | 2.46 |

| tag | 撞在哪 | 证据（edidada/compiler_script 的 run） |
| --- | --- | --- |
| rel-1.13.0 | `ld: cannot use executable file 'out/rom16.strip.o' as input to a link`；Makefile:185-187 把 `strip` 之后的 **ET_EXEC** 直接当链接输入 | 40210834518，三条腿同一 FATAL；22.04 报 `Makefile:187`、24.04/26.04 同一行 |
| rel-1.11.2 | 同上，Makefile:186 | 40210852091 |
| rel-1.9.3 | 先被该 tag 自带的 `scripts/test-build.sh` 的 **iasl** 硬门槛判 `-1`（`iasl` 检查在 1.11.2 起被上游删掉了；这条 gate 与 runner 无关，三条腿同一个判定）。就算装上 iasl 绕过，它的 Makefile:182-184 同样是 `rom16.strip.o` 流程，还是会撞上上面那堵墙 | 40210871035 |

为什么 rel-1.14.0 起就没这个问题：上游加了 `scripts/ldnoexec.py`，把规则从 `%.strip.o`
换成 `%.noexec.o`（strip 完再转成可重定位对象），链接输入不再是 ET_EXEC。按 tag 逐个读
Makefile 核过：`rel-1.14.0 / 1.16.0 / 1.16.1 / 1.16.2 / 1.16.3 / 1.15.0 / 1.17.0` 都是
`noexec.o` 流程，`rel-1.9.3 / 1.11.2 / 1.12.1 / 1.13.0` 都还是 `rom16.strip.o` 流程。

所以版本覆盖取"今天编得动"的那一整段：
`latest`、`rel-1.17.0`、`rel-1.16.3`、`rel-1.16.2`、`rel-1.16.1`、`rel-1.16.0`、
`rel-1.15.0`、`rel-1.14.0`（各一条 workflow，每条 3 个 ubuntu runner，全部跑绿）。
上面这套判据对所有固定版本分支同样适用。
