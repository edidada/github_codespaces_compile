#! /bin/bash
# Tengine 源码编译。分支名是 latest，所以取当前正式 release（3.1.0，2023-10-27 发布，
# 3.2.0 至今只有 rc 标签），内部基于 nginx 1.24.0。
#
# 2026-10-24（workflow 从已下线的 ubuntu-20.04 换成 ubuntu-latest 后，run 40056435654 失败）。
# 旧脚本三处都撑不到现在：
#
# (1) apt 那一行在 noble 上直接失败，实测（同 run 的完整日志）：
#       E: Package 'initscripts' has no installation candidate
#       E: Unable to locate package libgd2-xpm-dev
#       E: Unable to locate package libpcre0 / libpcre++-dev      （原文是 libpcre++0 / libpcre++-dev）
#     apt 只要有一个包装不上就整体退出，所以 libssl-dev / libpcre++-dev 一个都没装上，
#     后面 configure 才会说 “checking for PCRE library ... not found”。
#     注意：`libpcre++-dev` 是 PCRE 的 C++ wrapper，nginx 系列 configure 找的是 C 头 pcre.h
#     （在 libpcre3-dev 里），装错包了。
#
# (2) `--enable-mods-static=all` 在 tengine 3.1.0 的 auto/options 里已经不存在，
#     而 configure 遇到未知选项是 `error: invalid option`（auto/options:451），会直接终止。
#     `--with-ipv6` 只剩一句 deprecated 警告（auto/options:239），也一并去掉。
#
# (3) tengine-2.2.2（2016 年，基于 nginx 1.8.x）在 OpenSSL 3 下编不过，和 c/nginx_v 那边
#     放弃 1.8.1 是同一个原因，所以按分支语义升到 3.1.0。
set -euo pipefail
cd "$(dirname "$0")"

TENGINE_VERSION="3.1.0"
PREFIX="/usr/local/tengine"
WORK_DIR="$(pwd)/.work"
HTTP_PORT=18080
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR/run"

echo "==== 1. 依赖 ===="
sudo apt-get update -qq
# PCRE2 + PCRE1 都装：tengine 3.1.0（nginx 1.24 系）优先探测 PCRE2，这里让它探到什么都编得过
sudo apt-get install -y -qq build-essential git zlib1g-dev libpcre2-dev libpcre3-dev \
    libssl-dev libxslt1-dev libxml2-dev perl

echo "==== 2. 取源码 ===="
rm -rf tengine
git clone -q --depth 1 -b "$TENGINE_VERSION" https://github.com/alibaba/tengine.git tengine
cd tengine
echo "HEAD=$(git rev-parse --short HEAD)"
# 源码里的版本串必须等于目标版本；顺带把它内含的 nginx 基线版本打出来
grep -F "define TENGINE_VERSION    \"$TENGINE_VERSION\"" src/core/nginx.h
grep -E 'define (nginx_version|NGINX_VERSION)' src/core/nginx.h

echo "==== 3. configure ===="
./configure \
    --prefix="$PREFIX" \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_stub_status_module \
    --with-threads

echo "==== 4. make + install ===="
make -j"$(nproc)"
sudo make install
NGINX="$PREFIX/sbin/nginx"
[ -x "$NGINX" ] || { echo "FATAL: 没装出 $NGINX" >&2; find "$PREFIX" -maxdepth 2 -type f | head -20 >&2; exit 1; }

echo "==== 5. 版本 ===="
"$NGINX" -v 2>&1 | tee "$WORK_DIR/v.txt"
grep -F "Tengine/$TENGINE_VERSION" "$WORK_DIR/v.txt" >/dev/null \
    || { echo "FATAL: -v 里没有 Tengine/$TENGINE_VERSION" >&2; exit 1; }
"$NGINX" -V 2>&1 | tee "$WORK_DIR/V.txt"
for m in --with-http_ssl_module --with-http_v2_module --with-http_stub_status_module --with-threads; do
    grep -F -- "$m" "$WORK_DIR/V.txt" >/dev/null && echo "PASS: 编译进 $m" \
        || { echo "FATAL: 缺少 $m" >&2; exit 1; }
done
file "$NGINX"
ldd "$NGINX" | sed -n '1,8p'

echo "==== 6. 起服务实测 ===="
RUN="$WORK_DIR/run"
mkdir -p "$RUN/conf" "$RUN/logs"
sudo cp -r "$PREFIX/conf/." "$RUN/conf/"
cat > "$RUN/conf/test.conf" <<EOF
pid         $RUN/nginx.pid;
error_log   $RUN/error.log warn;
worker_processes 1;
events { worker_connections 64; }
http {
    include       $RUN/conf/mime.types;
    default_type  application/octet-stream;
    access_log    $RUN/access.log;
    server {
        listen      $HTTP_PORT;
        server_name localhost;
        root        $PREFIX/html;
        index       index.html;
        location / { }
        location = /stub_status { stub_status; }
    }
}
EOF
sudo "$NGINX" -p "$RUN" -c conf/test.conf -t
sudo "$NGINX" -p "$RUN" -c conf/test.conf
started=""
for i in $(seq 1 30); do
    if curl -fsS --max-time 3 "http://127.0.0.1:$HTTP_PORT/" -o "$WORK_DIR/resp.html" 2>/dev/null; then started=yes; break; fi
    sleep 1
done
[ -n "$started" ] || { echo "FATAL: 起来了但 $HTTP_PORT 没响应，error log 如下"; sudo cat "$RUN/error.log"; exit 1; }

code="$(curl -s -o "$WORK_DIR/http.html" -w '%{http_code}' "http://127.0.0.1:$HTTP_PORT/")"
echo "GET / -> $code"
[ "$code" = "200" ] || { echo "FATAL: 期望 HTTP 200" >&2; exit 1; }
grep -F 'Welcome to tengine' "$WORK_DIR/http.html" >/dev/null \
    || { echo "FATAL: 返回的页面不是 tengine 默认欢迎页" >&2; sed -n '1,10p' "$WORK_DIR/http.html"; exit 1; }
echo "PASS: 默认欢迎页来自本次编译的产物"

curl -fsS "http://127.0.0.1:$HTTP_PORT/stub_status" -o "$WORK_DIR/status.txt"
sed -n '1,4p' "$WORK_DIR/status.txt"
grep -F 'Active connections' "$WORK_DIR/status.txt" >/dev/null \
    || { echo "FATAL: stub_status 未生效" >&2; exit 1; }
echo "PASS: stub_status 生效"

echo "==== 7. reload + 退出 ===="
sudo "$NGINX" -p "$RUN" -c conf/test.conf -s reload
sleep 2
code="$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$HTTP_PORT/")"
echo "reload 后 GET / -> $code"
[ "$code" = "200" ] || { echo "FATAL: reload 后不再返回 200" >&2; exit 1; }
sudo "$NGINX" -p "$RUN" -c conf/test.conf -s quit
for i in $(seq 1 20); do
    curl -fsS --max-time 2 "http://127.0.0.1:$HTTP_PORT/" -o /dev/null 2>/dev/null || break
    sleep 1
done
curl -s --max-time 3 "http://127.0.0.1:$HTTP_PORT/" -o /dev/null \
    && { echo "FATAL: quit 之后 $HTTP_PORT 还在监听" >&2; exit 1; }
echo "PASS: quit 后端口已释放"
echo "==== tengine $TENGINE_VERSION 源码编译与运行校验全部通过 ===="
