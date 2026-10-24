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

echo "==== 5. 校验安装树 ===="
[ -f /usr/local/include/Poco/Environment.h ] || { echo "FATAL: 头文件没装上" >&2; exit 1; }
ls -l --time-style=full-iso /usr/local/include/Poco/Environment.h
lib="$(ls /usr/local/lib/libPocoFoundation*.so 2>/dev/null | grep -v '\.so\.' | head -1)"
[ -n "$lib" ] || { echo "FATAL: /usr/local/lib 里没有 libPocoFoundation*.so" >&2; ls /usr/local/lib | head -20 >&2; exit 1; }
basename_lib="$(basename "$lib" | sed -e 's/^lib//' -e 's/\.so.*$//')"
echo "Foundation 库 = $lib （链接名 -l$basename_lib）"
file "$lib"

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
netlib="$(ls /usr/local/lib/libPocoNet*.so 2>/dev/null | grep -v '\.so\.' | head -1)"
[ -n "$netlib" ] || { echo "FATAL: 没装上 libPocoNet*.so" >&2; exit 1; }
netbase="$(basename "$netlib" | sed -e 's/^lib//' -e 's/\.so.*$//')"
g++ -O0 -o "$WORK_DIR/probe_net" "$WORK_DIR/probe_net.cpp" \
    -I/usr/local/include -L/usr/local/lib -l"$netbase" -l"$basename_lib" -Wl,-rpath,/usr/local/lib
out_net="$("$WORK_DIR/probe_net")"
echo "PocoNet 探针输出: $out_net"
echo "$out_net" | grep -F 'ip=127.0.0.1 has=1 value=ok' >/dev/null \
    || { echo "FATAL: PocoNet 的 IPAddress / MessageHeader 行为不符合预期" >&2; exit 1; }
echo "PASS: PocoNet 也能被链接并运行"
echo "==== poco $POCO_VERSION 源码编译、安装与运行校验全部通过 ===="
