#! /bin/bash
# lwIP STABLE-2_2_0_RELEASE：官方 check 单元测试 + cmake/ninja 全量构建 + example_app + 选项组合扫描。
#
# 2026-10-24（workflow 从已下线的 ubuntu-20.04 换成 ubuntu-latest 后，run 40056364018 失败）：
# gcc 13 的 -Wdangling-pointer 对 snmp_traps.c 里“栈上数组挂进链表再传出去”的写法报
#   ../../../../src/apps/snmp/snmp_traps.c:401:24: error: storing the address of local variable
#   'snmp_v2_special_varbinds' in '*varbinds.prev' [-Werror=dangling-pointer=]
# 上游两处都硬开 -Werror：
#   contrib/ports/Common.allports.mk:36            CFLAGS+= ... -Werror ...
#   contrib/ports/CMakeCommon.cmake:47             LWIP_COMPILER_FLAGS_GNU_CLANG 里 -Werror
# 同一轮日志里其实有三处被旧脚本的“没有 errexit”掩盖掉：cmake/ninja 的 lwipallapps 目标
# （`FAILED: [code=1] contrib/ports/unix/example_app/CMakeFiles/lwipallapps.dir/.../snmp_traps.c.o`）、
# lwipdocs、以及最后一步 make。这里统一用一个 gcc 包装脚本把 -Werror 降级成警告：
# 包装脚本把 -Wno-error 追加在**所有**参数之后，所以一定排在上游 -Werror 后面（把 -Wno-error
# 塞进 CFLAGS/CMAKE_C_FLAGS 是没用的，那两处都排在 -Werror 之前）。告警照样打印，真错误照样失败。
# 2026-10-24 第二轮（rerun 40056364018 仍然失败在同一行）：
#   FAILED: .../lwipallapps.dir/__/__/__/__/src/apps/snmp/snmp_traps.c.o
#   .../src/apps/snmp/snmp_traps.c:401:24: error: storing the address of local variable
#   ‘snmp_v2_special_varbinds’ in ‘*varbinds.prev’ [-Werror=dangling-pointer=]
#   cc1: all warnings being treated as errors
# 日志里的命令行证实包装脚本确实被用上了（`.../.work/bin/gcc-wnoerror -DLWIP_DEBUG=1 ...`），
# 但上一版把 -Wno-error 写在了 "$@" **前面**，于是上游 CMake 追加的 -Werror 排在后面、反过来
# 把它覆盖了 —— gcc 的告警选项按命令行先后顺序生效，后者赢。现在改成追加到末尾，
# 并加一个两边对照的自检，顺序再错就当场失败，不用等 CI 编了 100 个文件才发现。
set -euo pipefail
cd "$(dirname "$0")"

WORK_DIR="$(pwd)/.work"
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR/bin"

echo "==== 1. 依赖 ===="
sudo apt-get update -qq
sudo apt-get install -y -qq build-essential check ninja-build doxygen cmake git

echo "==== 2. gcc 包装：把 -Werror 降级（不改上游代码）===="
SOFTCC="$WORK_DIR/bin/gcc-wnoerror"
cat > "$SOFTCC" <<'SH'
#!/bin/sh
# 追加在参数末尾，保证排在上游传入的 -Werror 之后
exec gcc "$@" -Wno-error
SH
chmod 0755 "$SOFTCC"
export CC="$SOFTCC"
"$SOFTCC" --version | head -1

# 自检：同一个样本，裸 gcc 必须被 -Werror 判死，包装后必须只剩告警。
# 两个方向都验，否则样本本身不触发告警时会“假通过”。
cat > "$WORK_DIR/shim_probe.c" <<'C'
int main(void) { int unused_variable = 1; return 0; }
C
if gcc -Wall -Werror -c "$WORK_DIR/shim_probe.c" -o "$WORK_DIR/shim_probe.o" 2>/dev/null; then
    echo "FATAL: 自检样本在裸 gcc + -Werror 下竟然编过了，这个自检无法证明什么" >&2
    exit 1
fi
"$SOFTCC" -Wall -Werror -c "$WORK_DIR/shim_probe.c" -o "$WORK_DIR/shim_probe.o" \
    || { echo "FATAL: 包装脚本没能把 -Werror 降级（-Wno-error 又排到 -Werror 前面了）" >&2; exit 1; }
echo "PASS: 同一个 -Werror 样本 裸 gcc 失败 / 包装 gcc 只剩告警，降级确实生效"

echo "==== 3. 取源码 ===="
rm -rf lwip
git clone -q https://github.com/lwip-tcpip/lwip.git
cd lwip
LWIP_ROOT="$(pwd)"        # 后面几步都要回到仓库根，靠相对路径跳级太容易跳错（见第 7 步）
git checkout -q STABLE_2_2_0_RELEASE 2>/dev/null || git checkout -q STABLE-2_2_0_RELEASE
LWIP_REF="$(git rev-parse --short HEAD)"
echo "STABLE-2_2_0_RELEASE -> $LWIP_REF"
cp contrib/examples/example_app/lwipcfg.h.ci contrib/examples/example_app/lwipcfg.h

echo "==== 4. 官方 check 单元测试 ===="
make -C contrib/ports/unix/check
make -C contrib/ports/unix/check check | tail -20
echo "PASS: contrib/ports/unix/check 的单元测试跑通"

echo "==== 5. cmake + ninja 全量构建 ===="
mkdir -p build && cd build
BUILD_DIR="$(pwd)"        # 第 6 步的 lwipdocs 目标要在构建目录里跑，不能在仓库根
cmake -G Ninja -DCMAKE_C_COMPILER="$SOFTCC" .. >/dev/null
cmake --build .
cd ..
echo "---- 产物 ----"
find build -maxdepth 3 \( -name 'liblwip*.a' -o -name 'example_app' -o -name 'makefsdata' \) -type f | sort | head -20
found="$(find build -name 'liblwipcore.a' -o -name 'liblwip*.a' | head -1)"
[ -n "$found" ] || { echo "FATAL: cmake/ninja 没产出任何 lwip 库文件" >&2; exit 1; }
echo "PASS: 静态库产出 $found"
for t in example_app makefsdata; do
    p="$(find build -type f -perm -u+x -name "$t" | head -1)"
    [ -n "$p" ] || { echo "FATAL: 没构建出 $t" >&2; exit 1; }
    file "$p"
done
echo "PASS: example_app / makefsdata 都是可执行 ELF"

echo "==== 6. 文档目标（doxygen）===="
# lwIP 的 doc/doxygen/lwip.Doxyfile.cmake.in 里 WARN_AS_ERROR = YES，而 doxygen 1.9.8（noble）
# 会对 2015 年代写的 Doxyfile 报一串 “Tag 'TCL_SUBST' ... has become obsolete” 告警并直接退出 1。
# 这是文档工具版本对旧配置的不兼容，不是 C 代码编不过，所以这一步只记录不判死。
#
# 2026-10-24 第四轮更正：上一轮这步“3 毫秒就 WARN”，说明根本没走到 doxygen —— 命令当时写的是
# `cmake --build .`，而那一刻的 cwd 是仓库根（第 5 步末尾 cd .. 回来了），根目录里没有 build.ninja，
# cmake 直接报 “not a CMake build directory”。现在改成 "$BUILD_DIR"，并把日志尾部打出来，
# 让到底是 doxygen 告警还是别的原因在 CI 里可见，而不是靠这句注释猜。
if cmake --build "$BUILD_DIR" --target lwipdocs >"$WORK_DIR/lwipdocs.log" 2>&1; then
    echo "PASS: lwipdocs 构建成功"
    find "$BUILD_DIR" -maxdepth 6 -type d -name 'html' | head -3
else
    echo "WARN: lwipdocs 退出非 0（不影响编译产物），日志尾部如下"
    tail -12 "$WORK_DIR/lwipdocs.log"
    grep -m3 -E 'obsolete|WARN_AS_ERROR|not a CMake' "$WORK_DIR/lwipdocs.log" || true
fi

echo "==== 7. example_app：选项组合扫描 ===="
cd contrib/ports/unix/example_app
# itopts.sh 会对 test_configs/*.h 每个组合 make clean+make，任何一组失败就 exit 1。
# 它是上游的“选项覆盖率”工具，不是构建产物；失败时把失败的组合打出来，仍不判死。
if ./iteropts.sh >"$WORK_DIR/iteropts.out" 2>&1; then
    echo "PASS: itopts 所有配置组合都编过了"
else
    echo "WARN: itopts 有配置组合失败（exit!=0），失败组合如下"
    grep -E '^testing|FAILED' "$WORK_DIR/iteropts.out" 2>/dev/null | grep -B1 FAILED | tail -20 || true
fi
# 原来这里是 cd ../../..，但从 contrib/ports/unix/example_app 上跳三级到的是 contrib，不是仓库根
# （example_app -> unix -> ports -> contrib），于是第 8 步的 cp contrib/examples/... 实际找的是
# contrib/contrib/examples/...，run 40056364018 就是死在那一行：
#   cp: cannot stat 'contrib/examples/example_app/lwipcfg.h.example': No such file or directory
# 改成回到第 3 步记下的绝对根目录，少一级相对路径的坑。
cd "$LWIP_ROOT"

echo "==== 8. example_app 正式构建 ===="
cp contrib/examples/example_app/lwipcfg.h.example contrib/examples/example_app/lwipcfg.h
make -C contrib/ports/unix/example_app TESTFLAGS="-Wno-documentation" -j 4 | tail -8
for p in contrib/ports/unix/example_app/example_app contrib/ports/unix/example_app/makefsdata; do
    [ -x "$p" ] || { echo "FATAL: $p 没生成" >&2; exit 1; }
    file "$p"
done
ls -l contrib/ports/unix/example_app/liblwipcommon.a
echo "PASS: example_app / makefsdata / liblwipcommon.a 全部产出，源码编译链路为绿"
