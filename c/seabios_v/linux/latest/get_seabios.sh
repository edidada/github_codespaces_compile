#! /usr/bin/env bash
#
# SeaBIOS（coreboot/seabios）源码编译：一份脚本按 Kconfig 把三种固件目标各编一遍
# （QEMU 版 bios.bin / coreboot 载荷 bios.bin.elf / EFI 的 CSM 模块 Csm16.bin），
# 外加一份独立 VGA ROM（vgabios.bin），每个产物都校验存在、尺寸合法、版本串对得上。
#
# 上游：https://github.com/coreboot/seabios
# 文档：https://seabios.org/Developer_Documentation.html
#
# ---------------------------------------------------------------------------
# 为什么只铺 Linux（x86_64），不铺 macOS / Windows —— 逐条对着 Makefile 说的：
#   1) Makefile:60-66 的 COMMONCFLAGS 里硬写了 -m32 -march=i386 -mregparm=3，
#      要求 gcc 有 x86 的 32 位后端；
#   2) Makefile:27 LD32BIT_FLAG:=-melf_i386，链接器必须是 GNU ld 且有 elf_i386 目标；
#   3) Makefile:172-175 用 objdump -thr 导出 ELF section，再交给 scripts/layoutrom.py
#      生成三个 .lds 链接脚本 —— 整条流水线建立在 ELF 之上；
#   4) README:1-2 "This project implements an X86 legacy bios that is built with
#      standard GNU tools."
#   GitHub 的 macos-* runner 现在是 arm64（Apple Silicon），既不是 x86 宿主也没有
#   -melf_i386；windows-* runner 只有 MSVC / MinGW（PE/COFF 目标），同样喂不了 2)3)。
#   所以 macOS/Windows 不是"暂时没铺"，是上游构建体系不支持，铺了必然红。
# ---------------------------------------------------------------------------
# 两个必须知道的坑（都是从上游 Makefile 读出来的，不是猜的）：
#   A) Makefile:25 写的是 PYTHON=python。Ubuntu runner 上没有 python（只有 python3），
#      所以每条 make 都要显式 PYTHON=python3，否则 buildversion.py / layoutrom.py 直接挂。
#      rel-1.9.3 起 scripts/*.py 就是 py3-clean 的（已按 tag 逐个核对过 print/ord 用法）。
#   B) .config 会被 Makefile:95 -include 进来，target-y 完全由 CONFIG_QEMU /
#      CONFIG_COREBOOT / CONFIG_CSM / CONFIG_BUILD_VGABIOS 决定（Makefile:97-101）。
#      Kconfig 的 "Build Target" 是个 choice（src/Kconfig:7-30，default QEMU），
#      只写 .config 不够——必须 make olddefconfig 让 choice 真的切过去，再断言
#      .config 里那一行确实是 y，否则可能出现"三次都在编 QEMU"的假通过。
# ---------------------------------------------------------------------------
set -euo pipefail

# ==== 版本相关：固定版本分支只需要改这一行 ====
# 留空 = 自动取上游最新的正式 rel-* tag（latest 分支用）；
# 固定版本分支写死，例如 SEABIOS_TAG="rel-1.17.0"。
SEABIOS_TAG="${SEABIOS_TAG:-}"

SEABIOS_GIT_URL="${SEABIOS_GIT_URL:-https://github.com/coreboot/seabios.git}"
WORK_DIR="${WORK_DIR:-$(pwd)/_seabios_build}"
LOG_DIR="$WORK_DIR/logs"
ART_DIR="$WORK_DIR/artifacts"
SRC_DIR="$WORK_DIR/seabios"
TABLE="$WORK_DIR/table.tsv"
EXTRA_VER="${EXTRA_VER:--compiler_script}"
# 每条 make 都带上 PYTHON=python3（坑 A）
SB_PY=(PYTHON=python3)

sb_die() {
    echo "FATAL: $*" >&2
    exit 1
}

echo "==== 0. 宿主环境 ===="
uname -a
sed -n '1,6p' /etc/os-release || true
echo "gcc: $(gcc --version | sed -n '1p')"
echo "ld : $(ld --version | sed -n '1p')"
echo "python3: $(python3 --version)"
echo "nproc=$(nproc)"

# 架构门禁：见上面"为什么只铺 Linux"
host_arch="$(uname -m)"
case "$host_arch" in
    x86_64 | i386 | i686)
        echo "INFO: 宿主架构 $host_arch，GNU x86 ELF 工具链可用"
        ;;
    *)
        sb_die "SeaBIOS 需要 x86 宿主（-m32 + ld -melf_i386 + ELF objdump），当前架构 $host_arch"
        ;;
esac
echo "目标版本：${SEABIOS_TAG:-（未指定，将取上游最新正式 rel-* tag）}"

echo "==== 1. 依赖 ===="
sudo apt-get update -qq
sudo apt-get install -y -qq build-essential git python3 file binutils ca-certificates
# 32 位运行库。SeaBIOS 全程用 ld 直接链 ELF，不经 gcc 驱动，所以这两包装不上也常常编得过；
# 真正的判据是第 3 步上游自带的 scripts/test-build.sh，所以这里装失败只 WARN。
for p in gcc-multilib libc6-dev-i386; do
    if sudo apt-get install -y -qq "$p" >/dev/null 2>&1; then
        echo "PASS: 已安装 $p"
    else
        echo "WARN: $p 装不上（不同 ubuntu 版本包名/可用性有差异），继续；判据交给 test-build.sh"
    fi
done

echo "==== 2. 取源码 ===="
rm -rf "$WORK_DIR"
mkdir -p "$LOG_DIR" "$ART_DIR"
: >"$TABLE"
# 不用 --depth：buildversion.py 要 git describe --tags（scripts/buildversion.py:39），
# 浅克隆拿不到 tag 会把版本串退化成 "?"，产物里就认不出这是哪个 SeaBIOS 了。
git clone --quiet "$SEABIOS_GIT_URL" "$SRC_DIR" || sb_die "git clone 失败：$SEABIOS_GIT_URL"
cd "$SRC_DIR"

if [ -z "$SEABIOS_TAG" ]; then
    mapfile -t rel_tags < <(git tag --list 'rel-*' | grep -E '^rel-[0-9]+(\.[0-9]+)+$' | sort -V)
    if [ "${#rel_tags[@]}" -eq 0 ]; then
        sb_die "上游没找到形如 rel-<x.y.z> 的正式 tag，latest 的取版本规则需要更新"
    fi
    SEABIOS_TAG="${rel_tags[-1]}"
    echo "INFO: 自动选到最新正式 tag $SEABIOS_TAG（候选共 ${#rel_tags[@]} 个，已过滤 rc/pre 后缀）"
else
    if ! git rev-parse -q --verify "refs/tags/$SEABIOS_TAG" >/dev/null; then
        sb_die "tag $SEABIOS_TAG 在 $SEABIOS_GIT_URL 上不存在"
    fi
    echo "INFO: 使用固定 tag $SEABIOS_TAG"
fi
git checkout --quiet "$SEABIOS_TAG"
describe_now="$(git describe --tags)"
if [ "$describe_now" != "$SEABIOS_TAG" ]; then
    sb_die "checkout 后 git describe 得到 $describe_now，不是 $SEABIOS_TAG"
fi
echo "PASS: 已停在 $SEABIOS_TAG"
echo "commit: $(git log -1 --format='%H %cd %s' --date=short)"
echo "源文件行数：$(git ls-files | wc -l)"

echo "==== 3. 上游构建环境自检（scripts/test-build.sh）===="
# Makefile:113-116 每次 make 都会跑它，返回 -1 就直接 error。这里先单独跑一遍，
# 好处是失败信息能落在明确的步骤里，而不是被 make 的 error 上下文吞掉。
mkdir -p out
tb_out="$(OUT=out CC=gcc LD=ld sh scripts/test-build.sh 2>&1 || true)"
tb_verdict="$(printf '%s\n' "$tb_out" | sed -n '$p')"
echo "test-build.sh 输出：$(printf '%s' "$tb_out" | tr '\n' ' ')"
case "$tb_verdict" in
    0)  echo "PASS: 判定 0 —— 链接器对齐正常，且支持 -fwhole-program" ;;
    2)  echo "PASS: 判定 2 —— 当前 gcc 不启用 -fwhole-program，Makefile:118-121 会绕开，不算失败" ;;
    -1) sb_die "判定 -1 —— 这套 gcc/binutils 编不了 SeaBIOS（详见上面的 test-build.sh 输出）" ;;
    *)  sb_die "无法从输出里解析判定值（得到 '$tb_verdict'）" ;;
esac

# 把 out/ 下需要的子目录建全。目录清单从 Makefile 的 DIRS= 行解析，不写死。
# 为什么需要这一步（2026-10-26 ubuntu-26.04 的 VGA 腿实测撞到的）：
#   Makefile 只在 do-kconfig 的配方里 mkdir -p $(addprefix $(OUT), $(DIRS))，
#   而模式规则 `$(OUT)%.s: %.c` 和 `$(OUT)%.lds: %.lds.S` 都不把 $(OUT)autoconf.h
#   当依赖（规则头在 master 是 135/143 行、rel-1.17.0 是 136/144 行、rel-1.9.3 是
#   128/136 行；make 报错报的是配方那一行，rel-1.17.0 上就是日志里的 Makefile:138），
#   于是 -j 下 cc1 可能在 out/src/ 还没被 mkdir 之前就往里面写文件，报
#   "cannot open 'out/src/asm-offsets.s' for writing"。
#   上游自己的 CI 也是 make -j，所以这是个概率性 race，不是版本不支持。
sb_prepare_out() {
    local dirs d
    mkdir -p out
    dirs="$(sed -n 's/^DIRS=//p' Makefile | sed -n '1p')"
    if [ -z "$dirs" ]; then
        sb_die "Makefile 里没解析到 DIRS= 行，无法预建 out/ 子目录"
    fi
    for d in $dirs; do
        mkdir -p "out/$d"
    done
    echo "INFO: out/ 子目录按 Makefile 的 DIRS=（$dirs）预建完成"
}

# 单个 Kconfig 目标的完整流程：写种子 -> olddefconfig -> 断言开关真生效 -> 编 -> 验产物
# $1 = 标签；$2 = .config 种子（换行分隔，不要写注释行）；$3.. = 期望产物路径
sb_build() {
    local name="$1" seed="$2"
    shift 2
    local -a want=("$@")
    local kconfig_log="$LOG_DIR/$name-olddefconfig.log"
    local build_log="$LOG_DIR/$name-build.log"

    echo ""
    echo "---- [$name] 配置 ----"
    printf '%s\n' "$seed"
    rm -f .config .config.old
    printf '%s\n' "$seed" >.config
    make "${SB_PY[@]}" olddefconfig >"$kconfig_log" 2>&1 \
        || { tail -n 40 "$kconfig_log"; sb_die "[$name] make olddefconfig 失败" ; }

    # 坑 B：断言种子开关在 olddefconfig 之后仍然是 y（choice 真的切过去了）
    local s
    for s in $seed; do
        if ! grep -qxF "$s" .config; then
            echo "---- .config 里相关行 ----"
            grep -E '^(CONFIG_QEMU|CONFIG_COREBOOT|CONFIG_CSM|CONFIG_BUILD_VGABIOS|CONFIG_VGA_[A-Z_]+)=' .config || true
            sb_die "[$name] 期望的配置行没生效：$s"
        fi
    done
    echo "PASS: [$name] 配置生效：$(grep -cE '^CONFIG_[A-Z0-9_]+=y$' .config) 个开关为 y"

    echo "---- [$name] 编译 ----"
    rm -rf out
    sb_prepare_out
    # 先单线程把 autoconf.h 做出来（这条规则会跑 silentoldconfig，顺带按上游逻辑建目录），
    # 再并行编剩下的，避开上面说的 mkdir race。
    if ! make "${SB_PY[@]}" out/autoconf.h >>"$build_log" 2>&1; then
        echo "---- $build_log 末尾 40 行 ----"
        tail -n 40 "$build_log"
        sb_die "[$name] 生成 out/autoconf.h 失败（Kconfig 头文件阶段）"
    fi
    if ! make "${SB_PY[@]}" -j"$(nproc)" EXTRAVERSION="$EXTRA_VER" >>"$build_log" 2>&1; then
        echo "---- $build_log 末尾 60 行 ----"
        tail -n 60 "$build_log"
        sb_die "[$name] SeaBIOS $SEABIOS_TAG 编译失败"
    fi
    # checkrom.py 的统计行 + buildversion.py 的 Version 行，直接抄进日志当证据
    sed -n '/^Version: /p;/^Total size: /p' "$build_log" || true

    local ver_file="out/autoversion.h"
    [ -f "$ver_file" ] || sb_die "[$name] 缺少 $ver_file（buildversion.py 没跑起来？）"
    local ver
    ver="$(sed -n 's/^#define BUILD_VERSION "\(.*\)"$/\1/p' "$ver_file" | sed -n '1p')"
    [ -n "$ver" ] || sb_die "[$name] 解析不出 BUILD_VERSION"
    case "$ver" in
        *"$SEABIOS_TAG"*) ;;
        *) sb_die "[$name] BUILD_VERSION '$ver' 里没有 $SEABIOS_TAG，版本串来源可疑" ;;
    esac

    local a sz dump line elfinfo sig blocks
    for a in "${want[@]}"; do
        [ -s "$a" ] || sb_die "[$name] 缺少产物 $a"
        sz="$(stat -c%s "$a")"
        line="$(printf '%-10s %-22s %10d bytes' "$name" "$(basename "$a")" "$sz")"

        # 产物里必须能找到自己的版本串（固件的身份证）
        dump="$(strings -n 4 "$a" || true)"
        case "$dump" in
            *"$ver"*) ;;
            *) sb_die "[$name] $(basename "$a") 里找不到版本串 $ver" ;;
        esac

        case "$a" in
            *.elf)
                # coreboot 载荷：必须是 x86 的 32 位 ELF
                elfinfo="$(file -b "$a")"
                case "$elfinfo" in
                    *"ELF 32-bit"*) ;;
                    *) sb_die "[$name] bios.bin.elf 不是 32 位 ELF：$elfinfo" ;;
                esac
                case "$elfinfo" in
                    *80386* | *Intel*) ;;
                    *) sb_die "[$name] bios.bin.elf 不是 80386 目标：$elfinfo" ;;
                esac
                echo "INFO: $a -> $elfinfo"
                ;;
            out/vgabios.bin)
                # 独立 option ROM：头两字节是 55AA，第 3 字节是按 512 字节算的块数
                sig="$(od -An -tx1 -N 2 "$a" | tr -d ' \n')"
                [ "$sig" = "55aa" ] || sb_die "[$name] vgabios.bin 起始签名是 $sig，不是 55aa"
                blocks="$(od -An -tu1 -j 2 -N 1 "$a" | tr -d ' ')"
                sz="$((sz))"
                if [ "$((blocks * 512))" -eq "$sz" ]; then
                    echo "INFO: vgabios.bin 头部自洽：block 字段 $blocks * 512 = $sz"
                else
                    sb_die "[$name] vgabios.bin 的 block 字段 $blocks 与尺寸 $sz 不一致"
                fi
                ;;
            *)
                # 系统 BIOS 镜像：checkrom.py 把镜像补齐到 64/128/256KiB（ROM_SIZE=0 时自动选）
                case "$sz" in
                    65536 | 131072 | 262144 | 524288 | 1048576) ;;
                    *) sb_die "[$name] $(basename "$a") 尺寸 $sz 不是合法 ROM 镜像大小" ;;
                esac
                ;;
        esac
        cp "$a" "$ART_DIR/$name--$(basename "$a")"
        printf '%s\t%s\t%s\n' "$name" "$(basename "$a")" "$sz" >>"$TABLE"
        echo "PASS: $line（版本串 $ver 已确认）"
    done

    # 反向断言：不属于本目标的产物不许出现（证明三次配置确实不同）
    local b
    for b in out/bios.bin out/bios.bin.elf out/Csm16.bin out/vgabios.bin; do
        local expected="no"
        local w
        for w in "${want[@]}"; do
            if [ "$w" = "$b" ]; then expected="yes"; fi
        done
        if [ "$expected" = "no" ] && [ -e "$b" ]; then
            sb_die "[$name] 不该产出 $b（说明 Kconfig 目标没真正切换）"
        fi
    done
}

echo "==== 4. 逐个 Kconfig 目标编译 ===="
# 4.1 默认目标：QEMU/Xen/KVM/Bochs 用的 bios.bin（src/Kconfig:7-9 的 choice 默认值）
sb_build "QEMU" "CONFIG_QEMU=y" "out/bios.bin"
# 4.2 coreboot 载荷：bios.bin.elf
sb_build "COREBOOT" "CONFIG_COREBOOT=y" "out/bios.bin.elf"
# 4.3 EFI 固件里的 CSM 模块：Csm16.bin
sb_build "CSM" "CONFIG_CSM=y" "out/Csm16.bin"
# 4.4 独立 VGA ROM：QEMU 目标 + Bochs VGA，产出 vgabios.bin（Makefile:101,248）
sb_build "VGA" "CONFIG_QEMU=y
CONFIG_VGA_BOCHS=y" "out/bios.bin" "out/vgabios.bin"

echo ""
echo "==== 5. 尽力用 qemu 真起一次（只 WARN，不作为失败条件）===="
# 为什么不作为失败条件：runner 上没有 /dev/kvm，只能跑 TCG；镜像里没有可引导设备，
# SeaBIOS 打完 banner 就停在"无可引导设备"上，最后靠 timeout 收场。这些和 SeaBIOS
# 本身能不能编、编出来的 rom 对不对没有关系，所以真正的判据始终是第 4 步的产物校验。
qemu_bin=""
for cand in qemu-system-x86_64 qemu-system-i386; do
    if command -v "$cand" >/dev/null 2>&1; then qemu_bin="$cand"; break; fi
done
if [ -z "$qemu_bin" ]; then
    if sudo apt-get install -y -qq qemu-system-x86 >/dev/null 2>&1; then
        if command -v qemu-system-x86_64 >/dev/null 2>&1; then
            qemu_bin="qemu-system-x86_64"
        fi
    fi
fi

if [ -n "$qemu_bin" ] && [ -s "$ART_DIR/QEMU--bios.bin" ]; then
    boot_log="$LOG_DIR/boot.log"
    rc=0
    timeout 120 "$qemu_bin" -machine q35 -m 256 -bios "$ART_DIR/QEMU--bios.bin" \
        -nographic -no-reboot -net none >"$boot_log" 2>&1 || rc=$?
    echo "INFO: $qemu_bin 退出码 $rc（124 = 到点被 timeout 收掉，属预期）"
    boot_out="$(cat "$boot_log" 2>/dev/null || true)"
    case "$boot_out" in
        *"SeaBIOS (version"*)
            echo "PASS: 在 qemu 串口输出里抓到了 SeaBIOS banner"
            printf '%s\n' "$boot_out" | grep -a 'SeaBIOS' || true
            ;;
        *)
            echo "WARN: 没抓到 SeaBIOS banner（runner 无 KVM/TCG 太慢/qemu 不可用都可能），不判死。boot.log 前 40 行："
            sed -n '1,40p' "$boot_log" || true
            ;;
    esac
else
    echo "WARN: 这台 runner 上没有可用的 qemu，跳过启动验证（产物校验已在第 4 步完成）"
fi

echo ""
echo "==== 6. 产物汇总 ===="
printf '%-10s %-22s %s\n' "配置" "产物" "字节"
while IFS=$(printf '\t') read -r cfg art sz; do
    printf '%-10s %-22s %s\n' "$cfg" "$art" "$sz"
done <"$TABLE"
echo "产物副本（已改名到 $ART_DIR，带 配置--文件名 前缀）："
( cd "$ART_DIR" && sha256sum -- * )
# PRETTY_NAME 才是 "Ubuntu 24.04.1 LTS" 这种完整串；VERSION_ID 只有版本号。
os_pretty="$(sed -n 's/^PRETTY_NAME=//p' /etc/os-release | sed -n '1p' | tr -d '"')"
echo "PASS: SeaBIOS $SEABIOS_TAG 在 $os_pretty 上完成 $(cut -f1 "$TABLE" | sort -u | tr '\n' ' ')四类 Kconfig 目标编译与校验"
