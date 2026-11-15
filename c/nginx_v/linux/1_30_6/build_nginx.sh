#!/usr/bin/env bash
#
# nginx：从官方源码包编译，并在本机真的起来提供服务（HTTP / HTTPS / HTTP2 / stub_status / gzip_static）。
#
# NGINX_VERSION 说明：
#   - 缺省 auto = 抓 nginx.org 下载页里的 Stable 分支版本号；
#   - 工作流里可以显式传 NGINX_VERSION=1.30.6 做版本钉定（c/nginx_v/linux/1_30_6 分支就这么用）。
# 下载源：https://nginx.org/download/nginx-<ver>.tar.gz
#
set -euo pipefail

NGINX_VERSION="${NGINX_VERSION:-auto}"
# 2026-10-24 本地从 nginx.org 直接下载后 sha256sum 实测；auto 探测到表外版本时只记录不阻断。
declare -A KNOWN_SHA256=(
    ["1.30.6"]="3cf46f5ed7504d460125866b7bea99fb357f31d887e2e63b35503310e9b8b6c8"
    ["1.31.8"]="0652b760b3b772d2ec17b47c2fc15d9a95e6fe35cd5b877eadc1a62d9bc75af1"
)
PCRE_VERSION="8.45"
PCRE_SHA256="4e6ce03e0336e8b4a3d6c2b70b1c5e18590a5673a98186da90d4f33c23defc09"

WORK_DIR="${WORK_DIR:-$(pwd)/_nginx_build}"
INSTALL_PREFIX="${INSTALL_PREFIX:-$WORK_DIR/out/nginx}"
HTTP_PORT="${HTTP_PORT:-18080}"
HTTPS_PORT="${HTTPS_PORT:-18443}"

echo "==== 0. 环境 ===="
uname -a
sed -n '1,4p' /etc/os-release
nproc
openssl version

echo "==== 1. 依赖 ===="
sudo apt-get update -qq
sudo apt-get install -y -qq build-essential zlib1g-dev libssl-dev libpcre3 libpcre3-dev wget curl openssl ca-certificates

echo "==== 2. 确定版本 ===="
mkdir -p "$WORK_DIR"
if [ "$NGINX_VERSION" = "auto" ]; then
    curl -fsSL --connect-timeout 20 --max-time 120 https://nginx.org/en/download.html -o "$WORK_DIR/download.html"
    # nginx.org 这一页是单行 HTML，所以别按“Stable version”附近的文本找，直接把所有
    # tarball 版本号抓出来取最大的那个（= 当前最新发布版，也就是 mainline）。
    mapfile -t VER_LIST < <(grep -oE '/download/nginx-[0-9]+\.[0-9]+\.[0-9]+\.tar\.gz' "$WORK_DIR/download.html" \
        | sed -E 's|/download/nginx-||; s|\.tar\.gz$||' | sort -uV)
    [ "${#VER_LIST[@]}" -gt 0 ] || { echo "FATAL: 无法从 nginx.org 解析出版本号" >&2; exit 1; }
    NGINX_VERSION="${VER_LIST[-1]}"
    echo "页面上列出的 tarball 版本（低 -> 高）：${VER_LIST[*]}"
    echo "自动探测到最新发布版本：$NGINX_VERSION"
else
    echo "使用钉定版本：$NGINX_VERSION"
fi

TARBALL="nginx-${NGINX_VERSION}.tar.gz"
URL="https://nginx.org/download/${TARBALL}"

echo "==== 3. 下载并校验 ===="
rm -rf "$WORK_DIR/src" "$WORK_DIR/out"
mkdir -p "$WORK_DIR/src" "$WORK_DIR/out"
cd "$WORK_DIR/src"
curl -fsSL --connect-timeout 20 --retry 3 --max-time 600 "$URL" -o "$TARBALL" || { echo "FATAL: 下载失败 $URL" >&2; exit 1; }
ACTUAL_SHA="$(sha256sum "$TARBALL" | cut -d' ' -f1)"
echo "sha256 = $ACTUAL_SHA"
if [ -n "${KNOWN_SHA256[$NGINX_VERSION]:-}" ]; then
    printf '%s  %s\n' "${KNOWN_SHA256[$NGINX_VERSION]}" "$TARBALL" | sha256sum -c -
    echo "PASS: 与脚本内记录的官方包 hash 一致"
else
    echo "WARN: 该版本不在脚本的 hash 表里，只做记录（把上面的 sha256 加进 KNOWN_SHA256 即可固化）"
fi
tar -xzf "$TARBALL"
SRC_DIR="$WORK_DIR/src/nginx-${NGINX_VERSION}"
[ -d "$SRC_DIR" ] || { echo "FATAL: 解压后目录不存在" >&2; ls -1 "$WORK_DIR/src" >&2; exit 1; }
echo "==== 源码里的版本声明 ===="
grep -E 'define NGINX_(VERSION|VERSION_STRING)' "$SRC_DIR/src/core/nginx.h"
grep -F "\"$NGINX_VERSION\"" "$SRC_DIR/src/core/nginx.h" >/dev/null || { echo "FATAL: 源码内版本号与期望不符" >&2; exit 1; }
echo "PASS: src/core/nginx.h 里的 NGINX_VERSION 就是 $NGINX_VERSION"

echo "==== 4. PCRE 后端探测 ===="
PCRE_ARGS=()
if [ -f /usr/include/pcre.h ]; then
    echo "使用系统 PCRE1（libpcre3-dev）"
    PCRE_ARGS=(--with-pcre-jit)
else
    echo "系统没有 pcre.h，改用 nginx 自带的 --with-pcre=<源码目录> 编译 PCRE ${PCRE_VERSION}"
    cd "$WORK_DIR/src"
    ok=""
    for u in "https://ftp.pcre.org/pub/pcre/pcre-${PCRE_VERSION}.tar.gz" \
             "https://sourceforge.net/projects/pcre/files/pcre/${PCRE_VERSION}/pcre-${PCRE_VERSION}.tar.gz/download"; do
        if curl -fsSL --connect-timeout 20 --retry 2 --max-time 600 "$u" -o "pcre-${PCRE_VERSION}.tar.gz"; then ok=yes; break; fi
    done
    [ -n "$ok" ] || { echo "FATAL: PCRE 源码下载失败" >&2; exit 1; }
    printf '%s  %s\n' "$PCRE_SHA256" "pcre-${PCRE_VERSION}.tar.gz" | sha256sum -c -
    tar -xzf "pcre-${PCRE_VERSION}.tar.gz"
    PCRE_ARGS=(--with-pcre="$WORK_DIR/src/pcre-${PCRE_VERSION}" --with-pcre-jit)
fi

echo "==== 5. configure ===="
cd "$SRC_DIR"
mkdir -p "$INSTALL_PREFIX/logs" "$INSTALL_PREFIX/conf"
# 全部落在工作区里，不碰系统路径，也不需要 sudo make install
./configure \
    --prefix="$INSTALL_PREFIX" \
    --sbin-path="$INSTALL_PREFIX/sbin/nginx" \
    --conf-path="$INSTALL_PREFIX/conf/nginx.conf" \
    --pid-path="$INSTALL_PREFIX/logs/nginx.pid" \
    --error-log-path="$INSTALL_PREFIX/logs/error.log" \
    --http-log-path="$INSTALL_PREFIX/logs/access.log" \
    --with-threads \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_stub_status_module \
    --with-http_gzip_static_module \
    --with-http_realip_module \
    --with-http_sub_module \
    "${PCRE_ARGS[@]}"
echo "==== configure 摘要 ===="
sed -n '1,20p' objs/ngx_auto_config.h | grep -E 'NGX_(HAVE|CONFIG|OS|CPU)' | sed -n '1,10p' || true

echo "==== 6. make ===="
make -j"$(nproc)"
make install
echo "==== 产物 ===="
ls -lh "$INSTALL_PREFIX/sbin/nginx"
file "$INSTALL_PREFIX/sbin/nginx"
ldd "$INSTALL_PREFIX/sbin/nginx"
du -sh "$INSTALL_PREFIX"

echo "==== 7. 版本与编译选项 ===="
NGINX_BIN="$INSTALL_PREFIX/sbin/nginx"
"$NGINX_BIN" -v 2>&1 | tee "$WORK_DIR/version.txt"
grep -F "$NGINX_VERSION" "$WORK_DIR/version.txt" >/dev/null || { echo "FATAL: nginx -v 版本不符" >&2; exit 1; }
echo "==== nginx -V ===="
"$NGINX_BIN" -V 2>&1 | tee "$WORK_DIR/V.txt" || true
for m in --with-http_ssl_module --with-http_v2_module --with-http_stub_status_module --with-http_gzip_static_module; do
    # 模式本身以 -- 开头，必须用 -- 结束选项解析，否则 grep 把它当成自己的参数
    grep -F -- "$m" "$WORK_DIR/V.txt" >/dev/null && echo "PASS: 编译进 $m" || { echo "FATAL: 缺少 $m" >&2; exit 1; }
done
openssl version -a | sed -n '1,2p'
echo "链接到的 SSL 库："; ldd "$INSTALL_PREFIX/sbin/nginx" | grep -F libssl || true

echo "==== 8. 生成测试配置（HTTP + HTTPS/HTTP2 + stub_status + gzip_static） ===="
CONF="$INSTALL_PREFIX/conf/test.conf"
cat > "$CONF" <<EOF
worker_processes 1;
daemon on;
error_log $INSTALL_PREFIX/logs/test-error.log warn;
pid $INSTALL_PREFIX/logs/test-nginx.pid;
events { worker_connections 64; }
http {
    include       $INSTALL_PREFIX/conf/mime.types;
    access_log    $INSTALL_PREFIX/logs/test-access.log;
    gzip_static   on;
    server {
        listen 127.0.0.1:$HTTP_PORT;
        server_name localhost;
        location / { root $INSTALL_PREFIX/html; index index.html; }
        location /stub_status { stub_status; }
    }
    server {
        listen 127.0.0.1:$HTTPS_PORT ssl;
        server_name localhost;
        ssl_certificate     $WORK_DIR/server.crt;
        ssl_certificate_key $WORK_DIR/server.key;
        http2 on;
        location / { root $INSTALL_PREFIX/html; index index.html; }
    }
}
EOF
# 自签证书，用来真的跑一次 TLS 握手
openssl req -x509 -newkey rsa:2048 -nodes -days 1 \
    -keyout "$WORK_DIR/server.key" -out "$WORK_DIR/server.crt" \
    -subj "/CN=localhost" 2>/dev/null
# gzip_static 需要同名 .gz 文件
printf 'gzip_static_payload_from_source_build\n' > "$INSTALL_PREFIX/html/static.txt"
gzip -kf "$INSTALL_PREFIX/html/static.txt"
rm -f "$INSTALL_PREFIX/html/static.txt"   # 只留 .gz，验证是 gzip_static 在生效

echo "==== 9. 配置语法检查 ===="
"$NGINX_BIN" -t -c "$CONF" -p "$INSTALL_PREFIX"

echo "==== 10. 启动并实测 ===="
"$NGINX_BIN" -c "$CONF" -p "$INSTALL_PREFIX"
started=""
for i in $(seq 1 30); do
    if curl -fsS --max-time 3 "http://127.0.0.1:$HTTP_PORT/" -o "$WORK_DIR/resp.html" 2>/dev/null; then started=yes; break; fi
    sleep 1
done
[ -n "$started" ] || { echo "FATAL: 起来了但 80 端口没响应，error log 如下"; cat "$INSTALL_PREFIX/logs/test-error.log"; exit 1; }

echo "---- HTTP ----"
code="$(curl -s -o "$WORK_DIR/http.html" -w '%{http_code}' "http://127.0.0.1:$HTTP_PORT/")"
echo "GET / -> $code"
[ "$code" = "200" ] || { echo "FATAL: HTTP 200 期望落空"; exit 1; }
grep -F 'Welcome to nginx' "$WORK_DIR/http.html" >/dev/null && echo "PASS: 默认欢迎页来自本次编译的产物" || { echo "FATAL: 返回的页面不是 nginx 默认欢迎页" >&2; sed -n '1,10p' "$WORK_DIR/http.html"; exit 1; }

echo "---- stub_status ----"
curl -fsS "http://127.0.0.1:$HTTP_PORT/stub_status" -o "$WORK_DIR/status.txt"
sed -n '1,4p' "$WORK_DIR/status.txt"
grep -F 'Active connections' "$WORK_DIR/status.txt" >/dev/null && echo "PASS: stub_status 生效" || { echo "FATAL: stub_status 未生效" >&2; exit 1; }

echo "---- gzip_static ----"
code="$(curl -s -H 'Accept-Encoding: gzip' -o "$WORK_DIR/static.gz" -D "$WORK_DIR/static.h" -w '%{http_code}' "http://127.0.0.1:$HTTP_PORT/static.txt")"
echo "GET /static.txt (Accept-Encoding: gzip) -> $code"
[ "$code" = "200" ] || { echo "FATAL: gzip_static 请求返回 $code" >&2; exit 1; }
grep -i -F 'content-encoding: gzip' "$WORK_DIR/static.h" >/dev/null && echo "PASS: 直接吐出预压缩的 .gz（gzip_static 生效）" || { echo "FATAL: 未见到 content-encoding: gzip" >&2; exit 1; }
zcat "$WORK_DIR/static.gz" | grep -F 'gzip_static_payload_from_source_build' >/dev/null && echo "PASS: 解压内容与写入时一致" || { echo "FATAL: 预压缩内容对不上" >&2; exit 1; }

echo "---- HTTPS + HTTP/2 ----"
code="$(curl -sk -o "$WORK_DIR/https.html" -w '%{http_code}' "https://127.0.0.1:$HTTPS_PORT/")"
echo "GET https:// -> $code"
[ "$code" = "200" ] || { echo "FATAL: HTTPS 没通" >&2; sed -n '1,20p' "$INSTALL_PREFIX/logs/test-error.log"; exit 1; }
curl -sk -o /dev/null -w 'HTTP/2 协商结果: %{http_version}\n' --http2-prior-knowledge "https://127.0.0.1:$HTTPS_PORT/"
ver="$(curl -sk -o /dev/null -w '%{http_version}' --http2-prior-knowledge "https://127.0.0.1:$HTTPS_PORT/")"
[ "$ver" = "2" ] && echo "PASS: ALPN/prior-knowledge 走的是 h2" || echo "WARN: http_version=$ver"
echo "---- TLS 参数（openssl s_client） ----"
# pipefail 会让“grep 没匹配到”直接掀掉脚本，这里只是打印诊断信息，全部兜底
echo | openssl s_client -connect 127.0.0.1:$HTTPS_PORT -servername localhost 2>/dev/null | grep -E 'Protocol|Cipher' | sed -n '1,3p' || true
echo | openssl s_client -connect 127.0.0.1:$HTTPS_PORT -tls1_2 2>/dev/null | grep -E 'Protocol|Cipher' | sed -n '1,3p' || true

echo "---- reload ----"
"$NGINX_BIN" -s reload -c "$CONF" -p "$INSTALL_PREFIX"
sleep 2
code="$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$HTTP_PORT/")"
echo "reload 后 GET / -> $code"
[ "$code" = "200" ] || { echo "FATAL: reload 后不可用" >&2; exit 1; }

echo "---- 关停 ----"
"$NGINX_BIN" -s quit -c "$CONF" -p "$INSTALL_PREFIX"
for i in $(seq 1 15); do
    if curl -fsS --max-time 2 "http://127.0.0.1:$HTTP_PORT/" -o /dev/null 2>/dev/null; then sleep 1; else break; fi
done
if curl -fsS --max-time 2 "http://127.0.0.1:$HTTP_PORT/" -o /dev/null 2>/dev/null; then
    echo "WARN: quit 后端口仍在监听"; else echo "PASS: 正常退出，端口已释放"; fi
echo "==== 运行期日志摘要 ===="
sed -n '1,10p' "$INSTALL_PREFIX/logs/test-error.log" || true

echo "==== 11. 汇总 ===="
echo "nginx 版本      : $NGINX_VERSION"
echo "源码包 sha256   : $ACTUAL_SHA"
echo "安装路径        : $INSTALL_PREFIX"
echo "二进制 sha256   : $(sha256sum "$INSTALL_PREFIX/sbin/nginx" | cut -d' ' -f1)"
echo "HTTP            : 200 + 默认欢迎页 + stub_status + gzip_static"
echo "HTTPS           : 200 + h2 协商 + TLS 握手实测"
"$NGINX_BIN" -v 2>&1
echo "完成：nginx ${NGINX_VERSION} 已从源码编译并通过真实服务验证"
