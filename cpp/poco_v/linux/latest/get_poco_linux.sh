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
ls -la build/compile_commands.json
cmake --build build -j5
ls -la build/compile_commands.json
#sudo cmake --install build
sudo cmake --build . --target install
