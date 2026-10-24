#! /bin/bash
# Pine（yuesong-feng/pine，C++17 epoll 网络库）源码编译 + 真的起 server 跑一次回环。
#
# 2026-10-24（workflow 从已下线的 ubuntu-20.04 换成 ubuntu-latest 后，run 40056514239 失败）：
#   src/Acceptor.cpp:20:3: error: 'assert' was not declared in this scope
#   note: 'assert' is defined in header '<cassert>'; did you forget to '#include <cassert>'?
# libstdc++ 13 收起了 <cassert>/<cstdint> 的传递包含，而上游用 assert() 的 5 个文件
# （Acceptor/Connection/Poller/Socket/TcpServer.cpp）都没自己 include。
# 这里不改上游代码，用 -include 在编译期把头塞进去（`grep -L` 实测这 5 个文件都缺）。
# 另外 pine 的 CMakeLists 里没有 -Werror（实测 grep 过），所以降级告警这件事在这儿不需要。
set -euo pipefail
cd "$(dirname "$0")"

ECHO_PORT=1234   # test/echo_server.cpp 用 TcpServer() 默认端口，echo_client.cpp 里写死 127.0.0.1:1234
WORK_DIR="$(pwd)/.work"
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"

echo "==== 1. 依赖 ===="
sudo apt-get update -qq
sudo apt-get install -y -qq build-essential cmake git

echo "==== 2. 取源码 ===="
rm -rf pine
git clone -q --depth 1 https://github.com/yuesong-feng/pine.git
cd pine
echo "HEAD=$(git rev-parse --short HEAD)  ($(git log -1 --format=%cd --date=short))"

echo "==== 3. configure（补上 gcc13 需要的头）===="
mkdir -p build && cd build
cmake .. -DCMAKE_CXX_FLAGS="-include cassert -include cstdint"

echo "==== 4. 可选的 lint 目标 ===="
# 这三个 target 是仓库自带的开发辅助（run_clang_format.py / cpplint / clang-tidy），
# 上游按 clang-8 时代写的，跟“能不能编出库”无关；原脚本也没把它们当失败（没有 errexit），
# 这里保持同样定位，只打一行结论。
make format      || echo "SKIP: make format 未通过（可选步骤，不影响产物）"
make cpplint     || echo "SKIP: make cpplint 未通过（可选步骤）"
make clang-tidy  || echo "SKIP: make clang-tidy 未通过（可选步骤）"

echo "==== 5. 编译库 ===="
make -j"$(nproc)"
lib="$(find . -type f -name 'libpine_shared.so*' | head -1)"
[ -n "$lib" ] || { echo "FATAL: 没产出 libpine_shared.so" >&2; find . -name '*.so*' | head >&2; exit 1; }
file "$lib"
echo "---- 导出符号抽查（C++ demangle）----"
nm -D --c++-filt "$lib" | grep -E 'TcpServer::(Start|TcpServer)|EventLoop::Loop' | head -6
n_sym="$(nm -D --c++-filt "$lib" | grep -c 'pine' || true)"
echo "INFO: 动态符号里含 pine 相关条目的行数=$n_sym"

echo "==== 6. 编译示例程序（证明库真的可链接）===="
# test/CMakeLists.txt 把每个 test/*.cpp 都做成 EXCLUDE_FROM_ALL 的 target，
# 产物落在 build/bin，所以按名字单独构建两个 server demo 和一个 client demo。
make echo_server echo_client http_server
ls -l bin/
for t in echo_server echo_client http_server; do
    [ -x "bin/$t" ] || { echo "FATAL: bin/$t 没生成" >&2; exit 1; }
    file "bin/$t"
done
ldd bin/echo_server | grep -F 'libpine_shared.so' >/dev/null \
    || { echo "FATAL: echo_server 没链到本次编出来的 libpine_shared.so" >&2; ldd bin/echo_server; exit 1; }
echo "PASS: echo_server 运行期依赖的就是本次构建的 libpine_shared.so"

echo "==== 7. 回环实测：echo server + client ===="
export LD_LIBRARY_PATH="$PWD:${LD_LIBRARY_PATH:-}"
./bin/echo_server > "$WORK_DIR/server.log" 2>&1 &
srv_pid=$!
trap 'kill $srv_pid 2>/dev/null || true' EXIT
up=""
for i in $(seq 1 30); do
    if (exec 3<>/dev/tcp/127.0.0.1/$ECHO_PORT) 2>/dev/null; then up=yes; break; fi
    sleep 1
done
[ -n "$up" ] || { echo "FATAL: echo_server 没在 $ECHO_PORT 上监听"; cat "$WORK_DIR/server.log"; exit 1; }
echo "echo_server 已监听 $ECHO_PORT (pid $srv_pid)"
# echo_client 从 stdin 逐行读、发送、再读回；EOF 后它会继续空转，所以用 timeout 收尾（124 是预期的）。
printf 'ping-1\nping-2\nping-3\nping-4\nping-5\n' > "$WORK_DIR/in.txt"
rc=0
timeout 25 ./bin/echo_client < "$WORK_DIR/in.txt" > "$WORK_DIR/client.log" 2>&1 || rc=$?
echo "echo_client 退出码=$rc（124=timeout 到点，属预期：上游 demo 在 stdin EOF 后不退出）"
sed -n '1,12p' "$WORK_DIR/client.log"
grep -E 'Message from server: ping-[0-9]' "$WORK_DIR/client.log" >/dev/null \
    || { echo "FATAL: 没收到服务端回送的 ping-*" >&2; echo "---- server.log ----"; cat "$WORK_DIR/server.log"; exit 1; }
echo "PASS: 本次编译的库真的完成了 TCP 收发回环"
echo "---- server.log ----"
grep -E 'Message from client' "$WORK_DIR/server.log" | sed -n '1,6p'
kill $srv_pid 2>/dev/null || true
wait $srv_pid 2>/dev/null || true
trap - EXIT
echo "==== pine 构建与回环实测全部通过 ===="
