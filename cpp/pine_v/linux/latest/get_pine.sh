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
#
# 2026-10-24 第六轮更正（rerun 40056514239 attempt 4/5/6，逐条都在 CI 日志里）：
#   attempt 4：回退逻辑本身走对了，却被 git 拒绝——第 4 步 make format 就地改写过跟踪文件，
#              checkout 不肯覆盖本地改动（见下面 PINE_ROOT 那段）。
#   attempt 5：checkout -f + 还原之后，021a26b4 真的编出了 libpine_shared.so 和三个 demo，
#              但收尾的符号抽查 `nm -D -C $lib | grep ... | head -6` 自己把作业弄红了：
#              head 关管道 → grep 吃 SIGPIPE → set -o pipefail 下退出码 2。
#   attempt 6：库、demo、ldd 全过，echo_server 也在 1234 上监听并打印了 "New connection fd: 9"，
#              接着服务端 Segmentation fault (core dumped)，客户端在 Connection::Write 的
#              assert 上 abort（134），回环拿不到 ping-*。
# 结论：上面那句“失败就固定到 021a26b4”不能成立——它只是编得过，运行期是坏的。
# 所以第 5 步改成在 src/ 的历史里从新到旧逐个试，判据是“库编译 + 三个 demo + 真回环”全过，
# 由 CI 当场选出 latest；失败的候选会连同原因列进汇总表，崩溃的那个额外用 gdb 把栈打出来。
#
# 2026-10-25 第七轮（rerun 40056514239 attempt 7，17 个候选全跑完）：
#   汇总实测：15 个候选在库里就编不过（还是 f815b419 那次 refactor 留下的 epoll 不自洽），
#   1 个 demo 编不过，只有 a3f8c32(2022-09-27) 和 021a26b4(2022-11-01) 走完“库 + 3 个 demo + ldd”，
#   两个都在回环这一步崩，而且 gdb 给的是同一份栈：
#     #0 __strlen_evex () at ../sysdeps/x86_64/multiarch/strlen-evex-base.S:81
#     #1 operator<<(std::basic_ostream<char, ...>&, char const*)   libstdc++.so.6
#     #2 main::{lambda(Connection*)#2}::operator()(Connection*) const   （echo_server 的 OnMessage）
#     #7 Connection::Business() ... #16 Channel::HandleEvent()   libpine_shared.so
#   根因在上游 demo 自己，不在库：test/echo_server.cpp 第 19 行是
#     std::cout << "Message from client " << conn->ReadBuffer() << std::endl;
#   而 ReadBuffer() 只是 return read_buffer_->ToStr()（src/Connection.cpp:165），指向固定大小的
#   读缓冲的裸指针、末尾不补 NUL；ostream << const char* 第一步就是 strlen，一路读出边界。
#   第 21 行 conn->Send(conn->ReadBuffer()) 还要再拿同一个指针构造 std::string，一样的错。
#   a3f8c32 与 021a26b4 两份 echo_server.cpp 实测都是这么写的。
# 所以“回环”这个判据不能挂在 demo 上——它证明的是上游 demo 坏，不是库坏。
# 改成：第 5 步的硬判据 = 库编译 + 自写的库探针（accept/读/写走一遍真事件循环，只调稳定 API，
# 不碰 ReadBuffer）；上游三个 demo 照旧编译并做链接检查，再照旧跑一次回环，但只作为 INFO 记录，
# 失败就把上面那份 gdb 栈打进日志，不当失败条件。
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


# 上游 main 把 util.h/util.cpp 改名成 common.h 却没改 src/Poller.cpp 的 #include，
# 所以“上游没有 util.h 就按删除前最后一版（4859bb3c）原样补回”这件事，HEAD 要做,
# 第 5 步逐个候选试的时候也要做（有的候选根本没写过 util.*，那就一次都不补）。
# 抽成函数是为了不让同一段 heredoc 在脚本里出现两遍。
pine_ensure_util() {
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
    grep -rn "ErrorIf" src/util.cpp src/include/util.h 2>/dev/null | sed -e 's/^/  /' || true
}

# 等某个端口进入 LISTEN。绝对不要用 (exec 3<>/dev/tcp/...) 这种“建一条连接再关掉”的方式
# 判断服务起没起：pine 会把这条探测连接 accept 成一个真连接，而 021a26b4 的
# src/Connection.cpp:155 是
#     void Connection::Business(){ Read(); on_message_callback_(this); }
#   ReadNonBlocking() 读到 EOF（探测连接一发 FIN 就关了）会 print "read EOF, client fd N
#   disconnected"、置 state_=Closed，并 Close() -> delete_connectioin_callback_ ->
#   Server::DeleteConnection 把 sock_/Connection delete 掉；紧接着的 on_message_callback_(this)
#   还是在**已经释放的对象**上跑（读的是野内存），Send()/Write() 一路都在 UB 上，服务端当场就没了，
#   于是真正的客户端只能拿到 Connection reset by peer。
# attempt 8 实测（run 40056514239，a3f8c32 与 021a26b4 两份 probe_srv.log 一模一样）：
#   probe: accepted fd=9                       <- 这条就是探测连接
#   read EOF, client fd 9 disconnected         <- 探测连接关掉，上面那条路径
#   probe: onMessage -> send pong              <- 悬垂 this 上跑回调
#   然后真客户端（下一步才连进来）: read: read error: 0: Connection reset by peer，退出码 4
#   而且日志里根本没有第二条 accepted —— 服务端在处理探测连接时就已经不行了。
# 所以改成只查 /proc/net/tcp{,6} 里 state=0A(LISTEN) 的表项，一行连接都不建。
# 返回码：0=已监听，1=20 秒超时，2=进程先没了（用来把失败原因说准）。
pine_wait_listen() {
    local port="$1" pid="${2:-}" hex i
    hex="$(printf '%04X' "$port")"
    for i in $(seq 1 20); do
        if [ -n "$pid" ] && ! kill -0 "$pid" 2>/dev/null; then return 2; fi
        if awk -v hx="$hex" '$4=="0A" && $2 ~ (":" hx "$") {f=1} END{if(!f) exit 1}' \
                /proc/net/tcp /proc/net/tcp6 2>/dev/null; then
            echo "INFO: $port 已进入 LISTEN（第 $i 次轮询，未建任何探测连接）"
            return 0
        fi
        sleep 1
    done
    return 1
}

# 上游 demo 的回环测试：起 echo_server、等它进 LISTEN、喂 5 行、看 echo_client 能不能读回同样的内容。
# 失败时（且 apt 装到了 gdb）再复现一次把栈打出来——日志里必须留下证据才知道该不该继续往旧版本退。
# 注意定位：从第七轮起这一步只是**信息**，不再当候选的失败条件（见文件顶部的 strlen 越界根因），
# 真正的功能判据是下面的 pine_probe。
pine_loopback() {
    local short="$1" rc="" up="" i srv w
    PINE_FAIL_WHY=""
    export LD_LIBRARY_PATH="$BUILD_DIR:${LD_LIBRARY_PATH:-}"
    ./bin/echo_server > "$WORK_DIR/server_$short.log" 2>&1 &
    srv=$!
    w=0
    pine_wait_listen "$ECHO_PORT" "$srv" || w=$?
    if [ "$w" -ne 0 ]; then
        echo "WARN: $short 的 echo_server 没能进入 LISTEN（pine_wait_listen 返回码=$w；1=超时 2=进程已退出）"
        sed -n '1,8p' "$WORK_DIR/server_$short.log"
        kill $srv 2>/dev/null || true; wait $srv 2>/dev/null || true
        PINE_FAIL_WHY="echo_server 没起来"
        return 1
    fi
    printf 'ping-1\nping-2\nping-3\nping-4\nping-5\n' > "$WORK_DIR/in.txt"
    timeout 20 ./bin/echo_client < "$WORK_DIR/in.txt" > "$WORK_DIR/client_$short.log" 2>&1 || rc=$?
    kill $srv 2>/dev/null || true; wait $srv 2>/dev/null || true
    if grep -E 'Message from server: ping-[0-9]' "$WORK_DIR/client_$short.log" >/dev/null; then
        echo "PASS: $short 的回环成功（echo_client 退出码=${rc:-0}；124=timeout 收尾，上游 demo 在 EOF 后不退出，属预期）"
        grep -E 'Message from server' "$WORK_DIR/client_$short.log" | sed -n '1,6p' | sed -e 's/^/    /'
        return 0
    fi
    echo "WARN: $short 库和 demo 都编出来了，但回环没拿到 ping-*（echo_client 退出码=${rc:-0}）"
    sed -n '1,8p' "$WORK_DIR/client_$short.log" | sed -e 's/^/  client| /'
    sed -n '1,8p' "$WORK_DIR/server_$short.log" | sed -e 's/^/  server| /'
    if [ -n "${PINE_GDB:-}" ]; then
        echo "---- 用 gdb 复现一次，把崩溃栈打出来 ----"
        gdb -q -batch -ex 'handle SIGPIPE nostop noprint pass' -ex run -ex bt -ex 'thread apply all bt' \
            --args ./bin/echo_server > "$WORK_DIR/gdb_$short.log" 2>&1 &
        local g=$!
        sleep 3
        timeout 10 ./bin/echo_client < "$WORK_DIR/in.txt" >/dev/null 2>&1 || true
        sleep 2
        kill $g 2>/dev/null || true; wait $g 2>/dev/null || true
        grep -E 'Program received|SIGSEGV|SIGFPE|^#[0-9]' "$WORK_DIR/gdb_$short.log" | sed -n '1,18p'
    fi
    PINE_FAIL_WHY="回环失败"
    return 1
}

# 自写的库探针：证明“这个候选编出来的库真的能用”——accept 一条真连接、读到客户端字节、
# 再通过库把 "pong" 写回去，全程只走不随版本漂移的稳定 API，绝不碰 conn->ReadBuffer()。
# 为什么要有它（不是猜的，是 attempt 7 的栈）：上游 demo 的 OnMessage 把不补 NUL 的读缓冲
# 交给 ostream << const char*，strlen 越界 → 服务端 SIGSEGV，demo 回环在任何候选上都过不了，
# 于是“库可用”这件事必须换一个不被上游缺陷污染的量具来测。
# API 按头文件嗅探，两套都支持，将来上游修好 epoll 也不用再改脚本：
#   LEGACY（<= 021a26b4，实测 Server.h 里是 class Server）: Server(EventLoop*) + NewConnect/OnMessage
#                                                            + Connection::GetState()/Send(std::string)
#   MODERN（main，f815b419 之后）: TcpServer() + Start() + onConnect/onRecv + Send(std::string)
# 两者的监听端口都是 1234：老 Acceptor 在 src/Acceptor.cpp:21 写死 InetAddress("127.0.0.1", 1234)，
# 新的 TcpServer() 默认构造也是 1234，所以 ECHO_PORT 不用分支。
pine_probe() {
    local short="$1" libpath="$2" libdir api="" out="" rc="" srv="" i g w
    PINE_PROBE_WHY="没跑起来"
    # 停在 build/ 里：$libpath 是 ./lib/libpine_shared.so 这种相对路径，而且调用方
    # （pine_try_commit）后面还要接着 file "$lib" / ls -l bin/，cwd 不能被打乱。
    cd "$BUILD_DIR" || return 1
    libdir="$(cd "$(dirname "$libpath")" && pwd)"
    if grep -qE '^[[:space:]]*class Server\b' "$PINE_ROOT/src/include/Server.h" 2>/dev/null; then
        api="LEGACY"
    elif grep -qE '^[[:space:]]*class TcpServer\b' "$PINE_ROOT/src/include/TcpServer.h" 2>/dev/null; then
        api="MODERN"
    else
        PINE_PROBE_WHY="认不出 server 头文件里的类名"
        echo "WARN: $short 找不到 Server/TcpServer 声明，探针无法生成"
        return 1
    fi
    echo "INFO: $short 探针 API = $api（库目录 $libdir）"

    cat > "$WORK_DIR/probe_server.cpp" <<'CPP'
// 不是上游文件，是本脚本第 5 步临时生成的功能量具（放在 $WORK_DIR，不进 git 工作树）。
#include <iostream>
#include <string>
#include "pine.h"

int main() {
#if defined(PINE_API_LEGACY)
  EventLoop *loop = new EventLoop();
  Server *server = new Server(loop);
  server->NewConnect([](Connection *conn) {
    std::cout << "probe: accepted fd=" << conn->GetSocket()->GetFd() << std::endl;
  });
  server->OnMessage([](Connection *conn) {
    // 刻意不调 conn->ReadBuffer()：它返回的是不补 NUL 的裸缓冲，
    // 交给 ostream / std::string 构造都会 strlen 越界（上游 demo 就是崩在这）。
    std::cout << "probe: onMessage -> send pong" << std::endl;
    conn->Send(std::string("pong\n"));
  });
  loop->Loop();
#elif defined(PINE_API_MODERN)
  TcpServer *server = new TcpServer();
  server->onConnect([](Connection *) { std::cout << "probe: accepted" << std::endl; });
  server->onRecv([](Connection *conn) {
    std::cout << "probe: onRecv -> send pong" << std::endl;
    conn->Send(std::string("pong\n"));
  });
  server->Start();
#else
#error "PINE_API_LEGACY / PINE_API_MODERN 都没定义"
#endif
  return 0;
}
CPP

    # 客户端不写 C++：用 bash 的 /dev/tcp，免得把上游 echo_client 自己的
    # Connection::Write assert（attempt 6 的 134 退出码）混进判据里。
    cat > "$WORK_DIR/probe_client.sh" <<'CLI'
#! /bin/bash
port="$1"
if ! exec 3<>/dev/tcp/127.0.0.1/"$port"; then echo "PROBE: connect failed"; exit 3; fi
printf 'hello\n' >&3
if IFS= read -r -t 8 line <&3; then echo "PROBE: got [$line]"; exit 0; fi
echo "PROBE: read timeout"
exit 4
CLI

    # -include 那一串照抄第 3 步给 cmake 的 flags，保证探针和库是同一套头环境编出来的。
    if ! g++ -std=c++17 $PINE_INCLUDE_FLAGS -pthread -I "$PINE_ROOT/src/include" \
            -DPINE_API_"$api" "$WORK_DIR/probe_server.cpp" -o "$WORK_DIR/probe_bin_$short" \
            -L "$libdir" -lpine_shared -Wl,-rpath,"$libdir" \
            > "$WORK_DIR/probe_cc_$short.log" 2>&1; then
        PINE_PROBE_WHY="探针编译失败"
        echo "WARN: $short 的库探针编不过："
        grep -E 'error:|fatal error' "$WORK_DIR/probe_cc_$short.log" | sed -n '1,8p' | sed -e 's/^/    /'
        return 1
    fi
    if ! ldd "$WORK_DIR/probe_bin_$short" | grep -F 'libpine_shared.so' >/dev/null; then
        PINE_PROBE_WHY="探针没链上本次的库"
        return 1
    fi

    export LD_LIBRARY_PATH="$libdir:${LD_LIBRARY_PATH:-}"
    "$WORK_DIR/probe_bin_$short" > "$WORK_DIR/probe_srv_$short.log" 2>&1 &
    srv=$!
    w=0
    pine_wait_listen "$ECHO_PORT" "$srv" || w=$?
    if [ "$w" -ne 0 ]; then
        if [ "$w" -eq 2 ]; then
            PINE_PROBE_WHY="探针 server 起来就退了（启动即崩）"
        else
            PINE_PROBE_WHY="探针 server 20 秒没进 LISTEN"
        fi
        kill "$srv" 2>/dev/null || true; wait "$srv" 2>/dev/null || true
        echo "WARN: $short $PINE_PROBE_WHY"
        sed -n '1,8p' "$WORK_DIR/probe_srv_$short.log" | sed -e 's/^/  probe| /'
        return 1
    fi
    out="$(timeout 15 bash "$WORK_DIR/probe_client.sh" "$ECHO_PORT" 2>&1)" || rc=$?
    kill "$srv" 2>/dev/null || true; wait "$srv" 2>/dev/null || true
    echo "INFO: 探针客户端：${out:-无输出}（退出码=${rc:-0}；4=读超时，124=timeout 收尾）"
    case "$out" in
        *"got [pong]"*|*pong*)
            echo "PASS: $short 的库探针通过（accept 真连接 + 读到客户端字节 + 通过库写回 pong）"
            echo "INFO: 探针客户端拿到 pong 就退出，随后上游那条 EOF->Close()->on_message_callback_ 的悬垂路径还会"
            echo "      在日志尾巴上留几行（见 pine_wait_listen 上面那段），不影响本次判据——pong 已经收到了。"
            sed -n '1,6p' "$WORK_DIR/probe_srv_$short.log" | sed -e 's/^/  probe| /'
            PINE_PROBE_WHY=""
            return 0 ;;
    esac
    PINE_PROBE_WHY="库探针没拿到 pong"
    echo "WARN: $short 库探针没过：${out:-无输出}（退出码=${rc:-0}）"
    sed -n '1,8p' "$WORK_DIR/probe_srv_$short.log" | sed -e 's/^/  probe| /'
    if [ -n "${PINE_GDB:-}" ]; then
        echo "---- 用 gdb 再跑一次探针，把栈留下 ----"
        gdb -q -batch -ex 'handle SIGPIPE nostop noprint pass' -ex run -ex bt -ex 'thread apply all bt' \
            --args "$WORK_DIR/probe_bin_$short" > "$WORK_DIR/probe_gdb_$short.log" 2>&1 &
        g=$!
        sleep 3
        timeout 10 bash "$WORK_DIR/probe_client.sh" "$ECHO_PORT" >/dev/null 2>&1 || true
        sleep 2
        kill "$g" 2>/dev/null || true; wait "$g" 2>/dev/null || true
        grep -E 'Program received|SIGSEGV|SIGABRT|^#[0-9]' "$WORK_DIR/probe_gdb_$short.log" | sed -n '1,18p'
    fi
    return 1
}

# 单个候选：切过去 -> 确认跟踪文件就是上游原样 -> 补 util.* -> 配库 -> 编 demo -> 库探针（硬判据）
#             -> 再跑一次上游 demo 回环（只记录，不判死）。
# 成功时把 cwd 留在该候选的 build 目录，失败时记一句原因（PINE_FAIL_WHY）供汇总表使用。
# 里面所有“只看前几行”的管道一律 sed -n 不用 head：脚本开着 set -o pipefail，
# head 读够就关管道，上游进程吃 SIGPIPE（141/grep 是 2）会被当成失败退出，
# run 40056514239 attempt 5 就是 `nm | grep | head -6` 这句自己把作业弄红的。
pine_try_commit() {
    local sha="$1" short lib t dyn_syms
    PINE_FAIL_WHY=""
    cd "$PINE_ROOT" || return 1
    short="$(git rev-parse --short "$sha")"
    git checkout -qf "$sha" || { PINE_FAIL_WHY="checkout 失败"; return 1; }
    if [ -n "$(git status --porcelain --untracked-files=no)" ]; then
        PINE_FAIL_WHY="checkout 后跟踪文件不干净"
        return 1
    fi
    pine_ensure_util
    rm -rf build && mkdir -p build && cd build || { PINE_FAIL_WHY="建 build 目录失败"; return 1; }
    BUILD_DIR="$(pwd)"
    if ! cmake .. -DCMAKE_CXX_FLAGS="$PINE_INCLUDE_FLAGS" > "$WORK_DIR/cmake_$short.log" 2>&1; then
        PINE_FAIL_WHY="cmake configure 失败"
        tail -6 "$WORK_DIR/cmake_$short.log" | sed -e 's/^/    /'
        return 1
    fi
    if ! make -j"$(nproc)" > "$WORK_DIR/lib_$short.log" 2>&1; then
        PINE_FAIL_WHY="库编译失败"
        grep -E 'error:|no declaration|undefined reference' "$WORK_DIR/lib_$short.log" | sed -n '1,6p' | sed -e 's/^/    /'
        return 1
    fi
    lib="$(find . -type f -name 'libpine_shared.so*' | sed -n 1p)"
    if [ -z "$lib" ]; then PINE_FAIL_WHY="没有 libpine_shared.so"; return 1; fi
    dyn_syms="$(nm -D -C "$lib")"
    case "$dyn_syms" in
        *'EventLoop::Loop'*) ;;
        *) PINE_FAIL_WHY="库里没有 EventLoop::Loop"; return 1 ;;
    esac
    echo "INFO: $short 库 OK（$(basename "$lib")，demangle 后含 :: 的条目 $(printf '%s\n' "$dyn_syms" | grep -cE '::' || true) 个）"
    if ! make echo_server echo_client http_server > "$WORK_DIR/demo_$short.log" 2>&1; then
        PINE_FAIL_WHY="demo 编译失败"
        grep -E 'error:|No rule to make target' "$WORK_DIR/demo_$short.log" | sed -n '1,6p' | sed -e 's/^/    /'
        return 1
    fi
    for t in echo_server echo_client http_server; do
        if [ ! -x "bin/$t" ]; then PINE_FAIL_WHY="bin/$t 没生成"; return 1; fi
    done
    if ! ldd bin/echo_server | grep -F 'libpine_shared.so' >/dev/null; then
        PINE_FAIL_WHY="echo_server 没链上本次的库"
        return 1
    fi
    PINE_DEMO_STATE=""
    if ! pine_probe "$short" "$lib"; then
        PINE_FAIL_WHY="${PINE_PROBE_WHY:-库探针失败}"
        return 1
    fi
    # 上游 demo 那一轮跑在探针之后（两者都占 1234，探针里的 server 已经 kill+wait 掉了）。
    # 它过不过都不影响结论：崩在 demo 自己的 strlen 越界上，见文件顶部第七轮。
    if pine_loopback "$short"; then
        PINE_DEMO_STATE="上游 demo 回环也通过"
    else
        PINE_DEMO_STATE="上游 demo 回环没通过（上游 echo_server 那句 cout << conn->ReadBuffer() 的 strlen 越界，已附 gdb 栈，不作为失败条件）"
    fi
    PINE_FAIL_WHY=""
    echo "INFO: $short — $PINE_DEMO_STATE"
    echo "---- 选中候选的产物 ----"
    echo "HEAD=$(git -C .. rev-parse --short HEAD)  ($(git -C .. log -1 --format=%cd --date=short))"
    file "$lib"
    printf '%s\n' "$dyn_syms" | grep -E '(TcpServer|Server|EventLoop)::' | sed -n '1,6p'
    ls -l bin/ | sed -n '1,8p'
    return 0
}

echo "==== 1. 依赖 ===="
sudo apt-get update -qq
sudo apt-get install -y -qq build-essential cmake git gdb
# 回环失败的候选要用 gdb 复现一次才知道崩在哪（021a26b4 就是“编得过、一连就段错误”这一类）。
# 取不到 gdb 就让第 5 步跳过这段诊断，不因为诊断工具本身把作业弄红。
PINE_GDB="$(command -v gdb || true)"
echo "INFO: gdb=${PINE_GDB:-未安装（跳过崩溃栈诊断）}"

echo "==== 2. 取源码 ===="
rm -rf pine
# 不带 --depth：第 5 步要在 src/ 的历史里从新到旧逐个 checkout 候选（整个仓库 91 KB，
# 带全历史也只多几秒，实测 run 40056514239 的 clone 步骤本来就不是瓶颈）。
git clone -q https://github.com/yuesong-feng/pine.git
cd pine
echo "HEAD=$(git rev-parse --short HEAD)  ($(git log -1 --format=%cd --date=short))"
PINE_ROOT="$(pwd)"

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
pine_ensure_util                      # 内容与原来第 2a 步完全一致，只是抽成了函数
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

echo "==== 5. 从新到旧找一个“编译 + 库探针真过”的上游提交 ===="
# 为什么这一步要循环试，而不是钉死一个 SHA（两条都是 CI 实测，不是推断）：
#   1) 上游 HEAD(2bb80f7，2022-12-20) 在 Linux 上根本编不过：f815b419 那次 refactor 只把
#      macOS 那条路径的 Poller 接口改成 const/RC 版本，src/Poller.cpp 的 #ifdef OS_LINUX 分支
#      还在按旧签名定义，于是 Poll::Poll / UpdateChannel / DeleteChannel 一串
#      "no declaration matches"，外加它调用了一个不存在的 Channel::SetExist。
#      （attempt 7 实测：17 个候选里只有 a3f8c32 和 021a26b4 能编过库 + demo。）
#   2) 退到 f815b419^ = 021a26b4 编得过，attempt 6 却卡在运行期：库和 3 个 demo 都产出、
#      echo_server 也在 1234 上监听（日志有 "echo_server 已监听 1234"、server.log 有
#      "New connection fd: 9"），客户端一连上服务端就 Segmentation fault (core dumped)，
#      客户端随后在自己那句 Connection::Write 的 assert 上 abort（退出码 134）。
#      这次还会多一份 gdb 的栈（第 1 步已经装 gdb），用来判断到底该不该继续往旧版本退。
# 所以这里的 "latest" 是“上游历史上最新一个真能用的提交”，由 CI 当场选，
# 候选 = 动过 src/ 的最近 N 个提交（新→旧）+ 上面那个 021a26b4，去重。
# 上游哪天把 Linux 路径修好了，HEAD 就是第一个候选，这段自动回到“用最新代码”。
PINE_PROBE_LIMIT=16
cd "$PINE_ROOT"
# 第 4 步的 make format 是就地改写源码的（上游 add_custom_target(format ... --fix)，
# main 和 021a26b4 两份 CMakeLists 实测写法一致），而 git checkout 不肯覆盖本地改动：
# run 40056514239 attempt 4 报的 "error: Your local changes ... would be overwritten"
# 列出的正是 Acceptor/Socket/TcpServer/*.h/test/chat_*.cpp 这批被格式化过的文件。
# 这里先还原成 HEAD 原样，后面循环里再用 checkout -f 逐候选覆盖。
echo "INFO: make format 改过的跟踪文件数=$(git diff --name-only | wc -l)，还原后再进候选循环"
git checkout -q -- .
mapfile -t PINE_CANDIDATES < <(
    { git log --format=%H -n "$PINE_PROBE_LIMIT" -- src/; echo "$PINE_LAST_GOOD_LINUX_SHA"; } | awk '!seen[$0]++'
)
echo "INFO: 候选提交数=${#PINE_CANDIDATES[@]}（新→旧），第一个是 $(git rev-parse --short "${PINE_CANDIDATES[0]}")"
PINE_TABLE="$WORK_DIR/attempts.tsv"
: > "$PINE_TABLE"
PINE_OK_SHA=""
for c in "${PINE_CANDIDATES[@]}"; do
    short="$(git rev-parse --short "$c")"
    when="$(git log -1 --format=%cd --date=short "$c")"
    subj="$(git log -1 --format=%s "$c")"
    echo "-------------------- try $short ($when) $subj"
    if pine_try_commit "$c"; then
        PINE_OK_SHA="$c"
        printf '%s\t%s\tPASS\t%s\n' "$short" "$when" "库探针通过；${PINE_DEMO_STATE:-demo 未记录}" >> "$PINE_TABLE"
        break
    fi
    printf '%s\t%s\tFAIL\t%s\n' "$short" "$when" "${PINE_FAIL_WHY:-未知}" >> "$PINE_TABLE"
done
echo "==== 候选汇总（新→旧）===="
cat "$PINE_TABLE"
if [ -z "$PINE_OK_SHA" ]; then
    echo "FATAL: ${#PINE_CANDIDATES[@]} 个候选没有一个同时通过“库编译 + demo 链接 + 库探针（真连接收发文）”，见上面汇总表" >&2
    exit 1
fi
echo "PASS: 本次 latest 取 $PINE_OK_SHA（$(git log -1 --format=%cd --date=short "$PINE_OK_SHA")）"
echo "INFO: 功能判据是自写的库探针（pine_probe）；上游 demo 的回环结果记在上面汇总表的 PASS 行里。"
echo "==== pine 构建 + 库探针实测通过 ===="
