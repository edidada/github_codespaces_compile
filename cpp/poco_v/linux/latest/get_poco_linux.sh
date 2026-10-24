#! /bin/bash
# POCO C++ Libraries 1.12.3 源码编译 + 安装 + 用装好的库真的跑起来。
#
# 2026-10-24（workflow 从已下线的 ubuntu-20.04 换成 ubuntu-latest 后，run 40056526394 失败）。
# 这一步跟镜像、编译器都无关，是脚本最后一行的目录写错了：
#   sudo cmake --build . --target install
# 当时 cwd 是 poco 源码根目录，而缓存目录是 build/（配置用的是 -S . -B build），
# 于是 cmake 直接 “Error: could not load cache”。实测日志尾部：
#   [100%] Built target DataPostgreSQL
#   -rw-r--r-- 1 runner runner 704175 Oct 24 03:00 build/compile_commands.json
#   Error: could not load cache
#   ##[error]Process completed with exit code 1.
# 也就是说库编出来了，但“安装”从来没执行过。正确写法是 `cmake --install build`。
# 旧脚本没有 errexit，前面任何一步失败都会被一路吞掉、只看最后一条命令的退出码，
# 所以这里补上 set -euo pipefail，并加上“装完之后真的能用”的实测。
#
# 2026-10-24 第二轮（rerun 40056526394）：编译 + 安装 + Foundation 探针全绿，最后一步 PocoNet
# 探针链接报 undefined reference to Poco::Net::…；原因是 Debug 构建的库名带 'd' 后缀，
# `ls libPocoNet*.so | head -1` 抓到的是 libPocoNetSSLd.so。修法与证据写在第 7 步。
set -euo pipefail
cd "$(dirname "$0")"

POCO_VERSION="1.12.3"
WORK_DIR="$(pwd)/.work"
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"

echo "==== 1. 依赖（和旧脚本同一份包名，noble 上实测装得上）===="
sudo apt-get update -qq
sudo apt-get install -y -qq build-essential cmake git openssl libssl-dev \
    libmysqlclient-dev libpq-dev

echo "==== 2. 取源码 + 版本对表 ===="
rm -rf poco
git clone -q --depth 1 --branch "poco-$POCO_VERSION-release" https://github.com/pocoproject/poco.git
cd poco
echo "HEAD=$(git rev-parse --short HEAD)  tag=$(git describe --tags --exact-match 2>/dev/null || echo '?')"
# poco 的 CMakeLists.txt 从仓库根的 VERSION / libversion 文件读版本号（实测：
# project(Poco) + file(STRINGS .../VERSION PACKAGE_VERSION)），所以拿 VERSION 文件对表
grep -F "$POCO_VERSION" VERSION
echo "PASS: 源码树 VERSION 文件 = $POCO_VERSION"

echo "==== 3. configure + build ===="
cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -G "Unix Makefiles" -S . -B build
ls -l build/compile_commands.json
cmake --build build -j"$(nproc)"
n_libs="$(find build -name 'libPoco*.so*' -type f | wc -l)"
echo "INFO: 构建目录里 libPoco*.so* 实体文件数 = $n_libs"
[ "$n_libs" -ge 10 ] || { echo "FATAL: 只产出 $n_libs 个 Poco 库，明显不全" >&2; exit 1; }
find build -maxdepth 3 -name 'libPoco*.so' -type f | sort | sed -n '1,12p'

echo "==== 4. install（旧脚本就是把这一行写错了）===="
sudo cmake --install build
# 刚装进 /usr/local/lib 的 .so 还不在动态链接器的缓存里：runner 的 ld.so 缓存是镜像构建时
# 生成的，不认识这些新文件。只链到“自己直接 NEEDED”的库的程序还能靠自身 RUNPATH 找到
# （第 6 步的 probe 就是这么过的），第 7 步却在这条路上翻了车：
#   error while loading shared libraries: libPocoFoundationd.so.93: cannot open shared object file
# 为什么同一个 rpath 一个能过一个不能过，见第 7 步里 readelf 的输出与那段推断。
# 这里先做“源码编译 + 安装”在真实机器上本该做的收尾：装完刷缓存。
sudo ldconfig
echo "INFO: ld.so 缓存里的 libPoco* 条目数=$(ldconfig -p | grep -c 'libPoco' || true)"

echo "==== 5. 校验安装树 ===="
[ -f /usr/local/include/Poco/Environment.h ] || { echo "FATAL: 头文件没装上" >&2; exit 1; }
ls -l --time-style=full-iso /usr/local/include/Poco/Environment.h
# head 读够就关管道，上游的 grep 会吃到 SIGPIPE（退出码 141/2）；脚本开着 set -o pipefail，
# 这种“诊断语句自己把作业弄红”的坑在 pine 那一版已经踩过一次（run 40056514239 attempt 5），
# 所以这里取第一行统一改用 sed -n 1p，不跟 head 赌时序。
lib="$(ls /usr/local/lib/libPocoFoundation*.so 2>/dev/null | grep -v '\.so\.' | sed -n 1p)"
[ -n "$lib" ] || { echo "FATAL: /usr/local/lib 里没有 libPocoFoundation*.so" >&2; ls /usr/local/lib | head -20 >&2; exit 1; }
basename_lib="$(basename "$lib" | sed -e 's/^lib//' -e 's/\.so.*$//')"
echo "Foundation 库 = $lib （链接名 -l$basename_lib）"
file "$lib"
# 这一步只确认第 4 步的 ldconfig 真的把新库写进了缓存；就算没写进去也不在这里判死，
# 因为下面两个探针还带 LD_LIBRARY_PATH 兜底，真正的判据是“程序能不能跑起来”。
if ldconfig -p | grep -F "lib$basename_lib" >/dev/null; then
    echo "PASS: lib$basename_lib 已进 ld.so 缓存：$(ldconfig -p | grep -F "lib$basename_lib" | sed -n 1p)"
else
    echo "WARN: ldconfig 后缓存里找不到 lib$basename_lib，第 6/7 步靠 LD_LIBRARY_PATH 兜底"
fi

echo "==== 6. 用装好的头+库编探针并运行（Foundation）===="
cat > "$WORK_DIR/probe.cpp" <<'CPP'
#include "Poco/Environment.h"
#include "Poco/NumberParser.h"
#include <cstdio>
int main() {
    // NumberParser / Environment 都是 libPocoFoundation 里的真实实现，
    // 能跑起来就证明安装出来的头 + 动态库是配套可用的。
    std::printf("hex=%u procs=%u libver=0x%08X\n",
                Poco::NumberParser::parseHex("FF"),
                static_cast<unsigned>(Poco::Environment::processorCount()),
                static_cast<unsigned>(Poco::Environment::libraryVersion()));
    return 0;
}
CPP
g++ -O0 -o "$WORK_DIR/probe" "$WORK_DIR/probe.cpp" \
    -I/usr/local/include -L/usr/local/lib -l"$basename_lib" -Wl,-rpath,/usr/local/lib
echo "---- 探针依赖解析 ----"
ldd "$WORK_DIR/probe" | grep -F "lib$basename_lib"
out="$("$WORK_DIR/probe")"
echo "探针输出: $out"
# libraryVersion() 返回编译进库里的 POCO_VERSION（0xAABBCCDD：major/minor/rev/patch），
# 这里只把它打出来当线索，不当断言 —— 编码方式不该由我来猜。
echo "$out" | grep -F 'hex=255' >/dev/null \
    || { echo "FATAL: Poco::NumberParser::parseHex(\"FF\") 没返回 255" >&2; exit 1; }
echo "PASS: 安装到 /usr/local 的 libPocoFoundation 运行期可用（parseHex 交叉验证）"

echo "==== 7. 再验一个跨组件的链接（PocoNet）===="
cat > "$WORK_DIR/probe_net.cpp" <<'CPP'
#include "Poco/Net/IPAddress.h"
#include "Poco/Net/MessageHeader.h"
#include <cstdio>
int main() {
    Poco::Net::IPAddress addr("127.0.0.1");
    Poco::Net::MessageHeader h;
    h.set("X-Probe", "ok");
    std::printf("ip=%s has=%d value=%s\n", addr.toString().c_str(),
                h.has("X-Probe") ? 1 : 0, h.get("X-Probe").c_str());
    return 0;
}
CPP
# 2026-10-24 第二轮（rerun 40056526394）：库编出来了、install 也过了、Foundation 探针也跑出
#   hex=255 procs=4 libver=0x010C0300
# 死的是这一步的链接：
#   undefined reference to `Poco::Net::IPAddress::IPAddress(std::__cxx11::basic_string<...> const&)'
#   undefined reference to `Poco::Net::MessageHeader::MessageHeader()'  …（NameValueCollection 的三个同样）
# 根因在库名，不在编译。CMAKE_BUILD_TYPE=Debug（旧脚本就是这么写的，这里沿用）会让 POCO 给
# 每个库名加一个 'd' 后缀，实测安装树里是
#   libPocoFoundationd.so -> libPocoFoundationd.so.93   libPocoNetd.so   libPocoNetSSLd.so
# 根本没有 libPocoNet.so。上一版用 `ls libPocoNet*.so | head -1` 取“第一个”，而在 C 排序下
# 'S'(libPocoNetSSLd.so) 排在 'd'(libPocoNetd.so) 前面，于是 -l 链到的是 NetSSL。
# NetSSL 只是 *依赖* Net；GNU ld 默认 --no-copy-dt-needed-entries，不会把间接 DT_NEEDED 库里的
# 符号借给主程序，所以 Net 的类全都“没定义”。
# 现在从 Foundation 的库名反推 Debug 后缀，精确拼出要链的那个库，并用 nm 先证明它真的实现了
# Poco::Net::IPAddress —— 链错了库会当场失败，而不是等 ld 报一堆 undefined。
#
# 2026-10-24 第四轮（上一轮 run 的日志）：FATAL 报“只找到 0 个符号”，但库本身是对的。
# 那句用的 `nm -D --c++-filt` 不是 GNU nm 的选项（demangle 只有 -C / --demangle，
# --c++-filt 是 llvm-nm 的），nm 打印 usage 后退出码非 0，管道里 grep 拿到空输入 -> 计数 0。
# 现在换成 -C，并且让 nm 的退出码不参与判断（|| true 已经在）。
suffix="${basename_lib#PocoFoundation}"        # Debug 构建 -> "d"，Release 构建 -> ""
netlib="/usr/local/lib/libPocoNet${suffix}.so"
[ -e "$netlib" ] || { echo "FATAL: 期望的 $netlib 不存在；安装树里的 PocoNet* 如下" >&2
                      ls /usr/local/lib | grep -F 'PocoNet' >&2 || true; exit 1; }
ls -l "$netlib"
netbase="$(basename "$netlib" | sed -e 's/^lib//' -e 's/\.so.*$//')"
echo "PocoNet 库 = $netlib （链接名 -l$netbase，Debug 后缀=[$suffix]）"
n_net="$(nm -D -C "$netlib" | grep -c 'Poco::Net::IPAddress::' || true)"
[ "${n_net:-0}" -ge 3 ] || { echo "FATAL: $netlib 里没有 Poco::Net::IPAddress 的实现（只找到 $n_net 个符号）" >&2; exit 1; }
echo "INFO: $netlib 导出 Poco::Net::IPAddress 相关符号 $n_net 个"
g++ -O0 -o "$WORK_DIR/probe_net" "$WORK_DIR/probe_net.cpp" \
    -I/usr/local/include -L/usr/local/lib -l"$netbase" -l"$basename_lib" -Wl,-rpath,/usr/local/lib
# 把“到底是谁需要谁”打出来，这样这条链路的结论是日志里的证据，不是注释里的推断。
# 上一轮的现象是：链接行明明带了 -Wl,-rpath,/usr/local/lib，第 6 步的 probe 也能跑，
# 偏偏第 7 步的 probe_net 在运行期找不到 libPocoFoundationd.so.93。
# 推断（下面 readelf 的输出就是用来证伪它的）：Foundation 不在 probe_net 自己的 NEEDED 里
# （--as-needed 把它丢了），它只是 libPocoNet 的依赖；而 RUNPATH（新 ld 默认 --enable-new-dtags）
# 不像 RPATH 会作用于被依赖对象的查找，于是这条传递依赖只能回头查 ld.so 缓存 —— 缓存是镜像
# 构建时生成的，里面没有我们刚装的库。若 readelf 显示 Foundation 其实是 probe_net 的直接 NEEDED，
# 那这个推断就被推翻，得再看 LD_LIBRARY_PATH 生效前后的差别。
echo "---- probe_net 的 NEEDED / runtime path ----"
readelf -d "$WORK_DIR/probe_net" | grep -E 'NEEDED|RPATH|RUNPATH' || true
echo "---- $netbase 自己的 NEEDED / runtime path ----"
readelf -d "$netlib" | grep -E 'NEEDED|RPATH|RUNPATH' | head -8 || true
export LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH:-}"
ldd "$WORK_DIR/probe_net" | sed -n '1,12p'
out_net="$("$WORK_DIR/probe_net")"
echo "PocoNet 探针输出: $out_net"
echo "$out_net" | grep -F 'ip=127.0.0.1 has=1 value=ok' >/dev/null \
    || { echo "FATAL: PocoNet 的 IPAddress / MessageHeader 行为不符合预期" >&2; exit 1; }
echo "PASS: PocoNet 也能被链接并运行"
echo "==== poco $POCO_VERSION 源码编译、安装与运行校验全部通过 ===="
