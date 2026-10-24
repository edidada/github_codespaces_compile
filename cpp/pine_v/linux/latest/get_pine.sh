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
#
# 2026-10-24 第二轮（rerun 40056514239 仍然失败，两处新坑）：
#   src/include/Connection.h:38:11: error: 'std::string' has not been declared
#   src/include/Connection.h:53:8:  error: 'unique_ptr' in namespace 'std' does not name a template type
#     note: 'std::unique_ptr' is defined in header '<memory>'; did you forget to '#include <memory>'?
#   src/Connection.cpp:65:5: error: 'memset' was not declared in this scope
#   src/Poller.cpp:17:10: fatal error: util.h: No such file or directory
# 前三类还是“用了但没 include”，把 -include 的清单从闭包分析里补齐（见下面 PINE_INCLUDE_FLAGS）。
# 最后一条不是编译器版本问题：上游 main 自己就没有 util.h，见 2a 步。
#
# 2026-10-24 第三轮（rerun 40056514239 attempt 3；-include 清单生效后往前推进了一大步）：
#   src/Poller.cpp:37:24: error: no declaration matches ‘std::vector<Channel*> Poller::Poll(int)’
#   src/Poller.cpp:58:6:  error: no declaration matches ‘void Poller::UpdateChannel(Channel*)’
#   src/Poller.cpp:79:6:  error: no declaration matches ‘void Poller::DeleteChannel(Channel*)’
# 这三条跟镜像、编译器都无关，是上游 main 自己不自洽。实测两份文件的历史：
#   gh api "repos/yuesong-feng/pine/contents/src/include/Poller.h?ref=f815b419"
#     -> RC UpdateChannel(Channel *ch) const;  RC DeleteChannel(...) const;  Poll(long timeout) const;
#   gh api ".../src/Poller.cpp?ref=f815b419"
#     -> #ifdef OS_LINUX 那一段仍是 void Poller::UpdateChannel(Channel*) / Poll(int)，
#        只有下面 #ifdef OS_MACOS 那一段跟着改成了 const/RC；而 Linux 上 CMakeLists 传的
#        是 -DOS_LINUX（根 CMakeLists.txt 的 CMAKE_SYSTEM_NAME MATCHES "Linux" 分支），
#        编的就是那段没改完的旧代码，还顺带用了早就不存在的 Channel::SetExist。
# 也就是说 refactor（f815b419，2022-11-04）只把 kqueue 那条路修完了，epoll 那条路从那天起
# 就没自洽过。这类“上游 tip 编不过”的情况，latest 分支按仓库里的既有做法取“最新可用版本”：
# 先照 main 试，失败就固定到 refactor 的父提交 021a26b4 —— 实测那时候 Poller.h 是
# `void UpdateChannel(Channel *ch)`、Poller.cpp 也是 `void Poller::UpdateChannel(Channel *)`，
# src/include/util.h、src/util.cpp、src/Server.{h,cpp} 都还在，test/echo_server.cpp 用的
# Server API 也在。上游哪天把 epoll 分支补齐，脚本会先在 main 上编成功，自动回到 main。
set -euo pipefail
cd "$(dirname "$0")"

ECHO_PORT=1234   # 两条路径都是 1234：main 用 TcpServer() 的默认端口，回退目标 021a26b4 是在
                 # src/Acceptor.cpp:21 写死 InetAddress("127.0.0.1", 1234)（实测抓过那份文件）；
                 # echo_client.cpp 两个版本都写死 127.0.0.1:1234，所以这一步不用分支判断。
# gcc 13 / libstdc++ 20 收紧了传递包含，下面这份清单是把 main 全仓库（src/ + test/ 共 30 个
# TU）的 #include 闭包逐个算出来后，取“用了但整个闭包里都没有”的头并集。
# 实测清单（2026-10-24，clone 当天 main）：
#   Acceptor.cpp/Connection.cpp/Poller.cpp/Socket.cpp/TcpServer.cpp -> cassert
#   Connection.cpp -> cstring(cstr* / memset / memcpy) cstdio(printf/perror) utility(std::move)
#   include/Connection.h -> memory(unique_ptr) string(std::string)      <- run 40056514239 报的就是这两个
#   include/Socket.h include/TcpServer.cpp -> cstdint                   <- run 40056514239 第一轮报的
#   include/ThreadPool.h -> atomic stdexcept      include/common.h -> cassert
#   test/echo_clients.cpp -> cstdio   test/echo_server.cpp -> cstdlib
PINE_INCLUDE_FLAGS="-include cassert -include cstdint -include cstring -include cstdio \
-include cstdlib -include memory -include string -include utility -include atomic \
-include stdexcept"
# 上游 Linux 路径（-DOS_LINUX 那段）自洽的最后一个提交 = 破坏性 refactor f815b419 的父提交。
# 只在 main 编不过时回退到这里；main 修好后这段代码路径不会再走到。
# 回退之后第 5/6/7 步的假设都按这个提交实测核对过（gh api 抓的 contents）：
#   树里 49 个条目，src/include/util.h、src/util.cpp、src/include/Server.h、src/Server.cpp 自带；
#   src/CMakeLists.txt 用 file(GLOB_RECURSE src/*.cpp) + add_library(pine_shared SHARED)，
#   根 CMakeLists 的 CMAKE_LIBRARY_OUTPUT_DIRECTORY=build/lib、test 的 RUNTIME_OUTPUT_DIRECTORY=
#   build/bin，test/CMakeLists.txt 给每个 test/*.cpp 做 EXCLUDE_FROM_ALL target，
#   所以 make echo_server echo_client http_server 和 find libpine_shared.so* 都照旧成立；
#   类名在这个提交里还叫 Server（main 才改名 TcpServer），下面的符号抽查两种都认。
PINE_LAST_GOOD_LINUX_SHA=021a26b44e6d6f1b7868b0175439ce3124e6df25
WORK_DIR="$(pwd)/.work"
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"

echo "==== 1. 依赖 ===="
sudo apt-get update -qq
sudo apt-get install -y -qq build-essential cmake git

echo "==== 2. 取源码 ===="
rm -rf pine
# 不带 --depth：万一 main 编不过，还需要 checkout 到 PINE_LAST_GOOD_LINUX_SHA（整个仓库 91 KB，
# 带全历史也只多几秒，实测 run 40056514239 的 clone 步骤本来就不是瓶颈）。
git clone -q https://github.com/yuesong-feng/pine.git
cd pine
echo "HEAD=$(git rev-parse --short HEAD)  ($(git log -1 --format=%cd --date=short))"

echo "---- 2a. 把上游删掉的 util.h / util.cpp 原样补回（只在上游没有时补）----"
# Poller.cpp:17 写着 #include "util.h"，并用 ErrorIf() 5 次（25/40/72/75/81 行）。
# 但今天的 main 里没有任何 util.* —— 实测
#   gh api "repos/yuesong-feng/pine/git/trees/HEAD?recursive=1"  → 48 个条目，'util' 匹配 0 个
#   gh api "search/code?q=repo:yuesong-feng/pine+ErrorIf"        → 只有 src/Poller.cpp
# 这两样是 2022-11-04 的 refactor（f815b419，把 util.h 改名成 common.h）删掉的，
# Poller.cpp 的引用没跟着改，所以 main 本身不自洽，任何人 clone 都编不过。
# 下面按删除前最后一版（4859bb3c）原样取回；src/CMakeLists.txt 用的是
# file(GLOB_RECURSE ${PROJECT_SOURCE_DIR}/src/*.cpp)，补进来的 util.cpp 会被自动编进 libpine_shared。
# Poller.cpp 的原有一行既不删也不改，是让它的 #include 真的能找到文件。
if [ ! -e src/include/util.h ]; then
    cat > src/include/util.h <<'H'
/**
 * @file util.h
 * @author 冯岳松 (yuesong-feng@foxmail.com)
 * @brief
 * @version 0.1
 * @date 2022-01-04
 *
 * @copyright Copyright (冯岳松) 2022
 *
 */
#pragma once

void ErrorIf(bool condition, const char *msg);
H
    echo "INFO: 上游缺 src/include/util.h，已按 4859bb3c 补回"
else
    echo "INFO: 上游已有 src/include/util.h，不动它"
fi
if [ ! -e src/util.cpp ]; then
    cat > src/util.cpp <<'CPP'
/**
 * @file util.cpp
 * @author 冯岳松 (yuesong-feng@foxmail.com)
 * @brief
 * @version 0.1
 * @date 2022-01-04
 *
 * @copyright Copyright (冯岳松) 2022
 *
 */
#include "util.h"

#include <cstdio>
#include <cstdlib>

void ErrorIf(bool condition, const char *errmsg) {
  if (condition) {
    perror(errmsg);
    exit(EXIT_FAILURE);
  }
}
CPP
    echo "INFO: 上游缺 src/util.cpp，已按 4859bb3c 补回（ErrorIf 的实现）"
else
    echo "INFO: 上游已有 src/util.cpp，不动它"
fi
grep -n '#include "util.h"' src/Poller.cpp || echo "INFO: Poller.cpp 已经不 include util.h 了（上游自己修好了，本步只是没参照物）"
grep -rn "ErrorIf" src/util.cpp src/include/util.h | sed -e 's/^/  /' || true

echo "==== 3. configure（补上 gcc13 需要的头）===="
mkdir -p build && cd build
BUILD_DIR="$(pwd)"
cmake .. -DCMAKE_CXX_FLAGS="$PINE_INCLUDE_FLAGS"

echo "==== 4. 可选的 lint 目标 ===="
# 这三个 target 是仓库自带的开发辅助（run_clang_format.py / cpplint / clang-tidy），
# 上游按 clang-8 时代写的，跟“能不能编出库”无关；原脚本也没把它们当失败（没有 errexit），
# 这里保持同样定位，只打一行结论。
# 但要注意 make format 是**就地改写源码**的：上游 CMakeLists.txt 写的是
#   add_custom_target(format ${PINE_BUILD_SUPPORT_DIR}/run_clang_format.py ... --fix --quiet)
# 这个 --fix 就是 in-place（main 与回退目标 021a26b4 两份 CMakeLists 都实测抓过，写法一致），
# 跑完 src/ 和 test/ 下的跟踪文件就不再等于 HEAD 了。
# 这一步本身没问题，问题是后面第 5 步失败时要 git checkout 回退，checkout 不肯覆盖本地改动
# （run 40056514239 attempt 4 就是死在这：error: Your local changes ... would be overwritten，
# 列出的正好是 Acceptor/Socket/TcpServer/*.h/test/chat_*.cpp 这批被格式化过的文件）。
# 所以这里把改动行数打出来，第 5 步回退前再显式还原。
make format      || echo "SKIP: make format 未通过（可选步骤，不影响产物）"
make cpplint     || echo "SKIP: make cpplint 未通过（可选步骤）"
make clang-tidy  || echo "SKIP: make clang-tidy 未通过（可选步骤）"
echo "INFO: lint 步骤之后被改动的跟踪文件数=$(git diff --name-only | wc -l)（make format 就地格式化所致）"

echo "==== 5. 编译库（先按上游 main 试，不行再退到 Linux 路径自洽的最后一个提交）===="
cd "$BUILD_DIR"
main_sha="$(git -C .. rev-parse --short HEAD)"
if make -j"$(nproc)"; then
    echo "PASS: 上游 main（$main_sha）自己就编得过，不需要回退"
else
    echo "WARN: 上游 main（$main_sha）的 epoll 分支编不过（见上面那串 no declaration matches / SetExist）"
    echo "INFO: 按仓库里 latest 分支的既有做法取“最新可用版本”——回退到 $PINE_LAST_GOOD_LINUX_SHA"
    echo "      （= 把 Poller 签名改成 const/RC 的那个 refactor f815b419 的父提交）"
    cd ..
    # 回退前有两条东西挡着 git checkout，都得先清掉，而且要说清楚各是谁造成的：
    #   1) 第 4 步 make format 就地改写了 src/ 和 test/ 下的跟踪文件（run 40056514239 attempt 4
    #      报的正是 error: Your local changes to the following files would be overwritten by
    #      checkout: src/Acceptor.cpp / src/Socket.cpp / src/TcpServer.cpp / src/include/*.h /
    #      test/chat_*.cpp —— 那批被 clang-format 处理过的文件）。用 git checkout -- . 还原成
    #      HEAD 的原样，不改上游一行内容。
    #   2) 2a 步补的 util.h/util.cpp 在 main 上是未跟踪文件，而回退目标 021a26b4 里它们是上游
    #      自带的跟踪文件，checkout 会以“未跟踪文件会被覆盖”为由拒绝，所以先删掉我补的这两份，
    #      切过去之后由上游自己带出来。
    echo "INFO: 还原 make format 的就地改动：$(git diff --name-only | tr '\n' ' ')"
    git checkout -q -- .
    rm -f src/include/util.h src/util.cpp
    git checkout -q "$PINE_LAST_GOOD_LINUX_SHA"
    echo "HEAD=$(git rev-parse --short HEAD)  ($(git log -1 --format=%cd --date=short))"
    echo "---- 回退后必须是纯上游代码：跟踪文件要干净，且 util.h/util.cpp/Server 都由上游自带 ----"
    # 只看跟踪文件（--untracked-files=no）：build/ 里全是本次构建产物，它干不干净跟
    # “产物是不是上游源码编出来的”无关，不该拿它当判据。
    git status --porcelain --untracked-files=no
    [ -z "$(git status --porcelain --untracked-files=no)" ] \
        || { echo "FATAL: checkout 后仍有跟踪文件被改动，下面这份产物就不能算“上游源码编译”" >&2; exit 1; }
    for f in src/include/util.h src/util.cpp src/include/Server.h src/Server.cpp; do
        [ -f "$f" ] || { echo "FATAL: $PINE_LAST_GOOD_LINUX_SHA 里没有 $f" >&2; exit 1; }
    done
    echo "INFO: 这四个文件在该提交里都存在，Linux 路径的声明/定义也是配套的"
    rm -rf build && mkdir -p build && cd build
    BUILD_DIR="$(pwd)"
    cmake .. -DCMAKE_CXX_FLAGS="$PINE_INCLUDE_FLAGS"
    make -j"$(nproc)"
fi
lib="$(find . -type f -name 'libpine_shared.so*' | head -1)"
[ -n "$lib" ] || { echo "FATAL: 没产出 libpine_shared.so" >&2; find . -name '*.so*' | head >&2; exit 1; }
file "$lib"
echo "---- 导出符号抽查（C++ demangle）----"
# 注意：nm 没有 --c++-filt 这个选项（那是 c++filt/objdump 的说法），GNU nm 用的是 -C/--demangle。
# 上一版写 --c++-filt，nm 直接打了 usage 并按失败退出 —— 在 set -euo pipefail 下这就是一条
# 假故障（run 40056526394 attempt 3 的 Poco 版本就是这么倒在“库里没有符号”上的）。
# 类名也别说死：main 上是 TcpServer，回退到的 021a26b4 上叫 Server，两者都匹配 (Server)::。
nm -D -C "$lib" | grep -E '(TcpServer|Server|EventLoop)::' | head -6
n_sym="$(nm -D -C "$lib" | grep -cE '::' || true)"
echo "INFO: 动态符号里 demangle 后含 :: 的条目数=$n_sym"
nm -D -C "$lib" | grep -qF 'EventLoop::Loop' \
    || { echo "FATAL: 库里找不到 EventLoop::Loop 的实现，产物不可用" >&2; exit 1; }

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
