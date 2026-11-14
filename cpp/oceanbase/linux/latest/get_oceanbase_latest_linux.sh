#!/usr/bin/env bash
# ============================================================================
# OceanBase 编译脚本 —— Ubuntu 26.04 / x86_64
# 路径: cpp/oceanbase/linux/latest/get_oceanbase_latest_linux.sh
# ============================================================================
# 实测成功基线 (2026-10-17, 已跑通并产出 observer):
#   OS:      Ubuntu 26.04.1 LTS
#   机器:    12 核 / 23 GB 内存 / 31 GB swap
#   并行度:  -j4
#   耗时:    6484 秒 (1 小时 48 分)
#   编译器:  OceanBase 自带 devtools 里的 Clang 17.0.6
#            deps/3rd/usr/local/oceanbase/devtools/bin/clang++-17
#            —— 系统不需要装 clang!
#   版本:    5e8a63d29dae9fde5e962b8fcc7b167d438fc343
#   产物:    build_release/src/observer/observer          ~5.7 GB
#            build_release/src/observer/liboceanbase.so   ~6.1 GB
#   磁盘:    源码 + 构建产物约 56 GB
#
# 四个踩过才知道的坑 (本脚本已全部处理):
#   1. 新工具链直接编不过: 必须去掉 4 处 -Werror, 并给 9 处 strchr/strrchr
#      加 (char *) 强转(GCC 15 / C23 的严格指针类型检查), 否则 deps/easy
#      和 oblib 必挂。
#   2. 并行度要按内存算、不能按核数算: 每个 Unity 翻译单元约 4.6 GB,
#      -j12 会被 OOM Killer 杀掉(make: Error 137)。23 GB 内存只能 -j4。
#   3. 日志/计时别写 /tmp: Ubuntu 的 /tmp 是 tmpfs 内存盘, 既挤占编译内存,
#      重启还会丢失。这里统一写到 $OUT_DIR(持久路径)。
#   4. Link 阶段更吃内存: ld.lld 单个进程可达 8~12 GB, 并发链接会触发
#      疯狂换页(整机 SSH 都连不上)。所以 JOBS 上限压到 6。
#
# 运维提示(易错): 杀编译器时 pkill 模式里的 + 是正则元字符,
#   写成 pkill -x "clang++-17" 永远匹配不上; 正确写法:
#   pkill -f "clang[+][+]-17"
# ============================================================================

set -euo pipefail

OB_REPO="${OB_REPO:-https://github.com/oceanbase/oceanbase.git}"
OB_COMMIT="${OB_COMMIT:-5e8a63d29dae9fde5e962b8fcc7b167d438fc343}"
OB_DIR="${OB_DIR:-$HOME/oceanbase}"
OUT_DIR="${OUT_DIR:-$HOME/ob-build}"      # 持久路径, 不要用 /tmp (tmpfs)
MEM_PER_JOB_GB="${MEM_PER_JOB_GB:-5}"     # 每个编译作业约 4.6 GB, 取 5 留余量
CREATE_SWAP_GB="${CREATE_SWAP_GB:-0}"     # 内存不足时可设为 16
JOBS="${JOBS:-}"

log() { printf '\n\033[1;34m[ob-build]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[ob-build][WARN]\033[0m %s\n' "$*"; }
die() { printf '\n\033[1;31m[ob-build][FATAL]\033[0m %s\n' "$*" >&2; exit 1; }

mkdir -p "$OUT_DIR"
LOG="$OUT_DIR/ob-build.log"
TIME_FILE="$OUT_DIR/ob-build.time"
PATCH_FILE="$OUT_DIR/ob-ubuntu26.patch"

# 以实际权限决定是否需要 sudo: GitHub Actions 的 runner 是非 root 用户,
# 而本地/容器里通常是 root。两边都要能跑。
SUDO=""
if [[ "$(id -u)" -ne 0 ]]; then
  SUDO="sudo"
fi
log "权限模式: ${SUDO:-root}"

# ---------- 0. 环境自检 ----------
log "环境信息"
echo "  OS      : $(. /etc/os-release 2>/dev/null && echo "$PRETTY_NAME" || uname -a)"
echo "  CPU 核数: $(nproc)"
echo "  内存    : $(awk '/MemTotal/{printf "%.1f GB", $2/1048576}' /proc/meminfo)"
echo "  swap    : $(awk '/SwapTotal/{printf "%.1f GB", $2/1048576}' /proc/meminfo)"
AVAIL_GB=$(df -Pk "$HOME" 2>/dev/null | awk 'NR==2{print int($4/1048576)}')
echo "  可用磁盘: ${AVAIL_GB} GB"
(( AVAIL_GB < 60 )) && warn "可用磁盘 ${AVAIL_GB}GB < 建议 60GB, 编译中途可能磁盘写满"

# ---------- 1. 并行度: 按内存推导 ----------
auto_jobs() {
  local cores mem_gb jobs
  cores=$(nproc)
  mem_gb=$(awk '/MemTotal/{print int($2/1048576)}' /proc/meminfo)
  jobs=$(( mem_gb / MEM_PER_JOB_GB ))
  (( jobs < 1 )) && jobs=1
  (( jobs > cores )) && jobs=$cores
  (( jobs > 6 )) && jobs=6      # 经验上限: 再高收益递减, 且 Link 阶段易 OOM
  echo "$jobs"
}
JOBS="${JOBS:-$(auto_jobs)}"
log "编译并行度 -j${JOBS}  (推导方式: 内存 / ${MEM_PER_JOB_GB}GB, 上限 6)"

# ---------- 2. 可选: 补 swap ----------
if [[ "$CREATE_SWAP_GB" =~ ^[0-9]+$ ]] && (( CREATE_SWAP_GB > 0 )); then
  CUR_SWAP_GB=$(awk '/SwapTotal/{print int($2/1048576)}' /proc/meminfo)
  if (( CUR_SWAP_GB < CREATE_SWAP_GB )); then
    log "创建 ${CREATE_SWAP_GB}G swap"
    # runner 自带的 /swapfile 只有约 3 GB 且不能同名复用，必须用独立文件，
    # 否则 [[ ! -f /swapfile ]] 为假会直接跳过，16 GB 补不上去。
    SWAP_FILE="$HOME/ob-swapfile"
    if [[ ! -f "$SWAP_FILE" ]]; then
      $SUDO fallocate -l "${CREATE_SWAP_GB}G" "$SWAP_FILE" 2>/dev/null \
          || $SUDO dd if=/dev/zero of="$SWAP_FILE" bs=1M count=$((CREATE_SWAP_GB*1024)) status=none
      $SUDO chmod 600 "$SWAP_FILE"
      $SUDO mkswap "$SWAP_FILE"
      $SUDO swapon "$SWAP_FILE"
      echo "$SWAP_FILE none swap sw 0 0" | $SUDO tee -a /etc/fstab >/dev/null
    fi
    swapon --show || true
  fi
fi

# ---------- 3. 依赖 (Ubuntu 26 实测所需, 逐条对齐成功记录) ----------
if command -v apt-get >/dev/null 2>&1; then
  log "安装/补齐依赖"
  export DEBIAN_FRONTEND=noninteractive
  $SUDO apt-get update -qq
  $SUDO apt-get install -y --no-install-recommends \
    build-essential ccache mold sccache \
    cmake pkg-config ninja-build rpm \
    libssl-dev zlib1g-dev libaio-dev libncurses5-dev \
    bison flex libtool automake git \
    || die "依赖安装失败"
else
  die "本脚本面向 Ubuntu(需要 apt-get)"
fi

# ---------- 4. 获取源码 (默认 pin 到实测成功的 commit) ----------
if [[ ! -d "$OB_DIR/.git" ]]; then
  log "克隆 OceanBase 源码 -> $OB_DIR"
  git clone "$OB_REPO" "$OB_DIR" || die "克隆失败"
else
  log "复用已有目录 $OB_DIR, 更新 refs"
  git -C "$OB_DIR" fetch --all --prune || true
fi
git -C "$OB_DIR" checkout -f "$OB_COMMIT" || die "无法切换到 $OB_COMMIT"
git -C "$OB_DIR" log -1 --format="  检出: %H%n  提交: %s%n  时间: %cd"

# ---------- 4.5 补齐 CMakeLists 引用但仓库未提交的目录 ----------
# unittest/sql/engine/op_tests/CMakeLists.txt 有
#   file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/test_data DESTINATION ...)
# 而该目录在 pin 的 commit 里并不存在（已确认不是 submodule / LFS，仓库
# 也没有 .gitmodules / .gitattributes）。CMake 4.x 对缺失源直接报
# "file COPY cannot find ..."（CMake 3.x 只是静默/警告），导致
# [build.sh][ERROR] Failed to generate Makefile。
# 本脚本编译的是 observer（release），不需要 unittest 的测试数据；
# 建一个带占位文件的目录让 configure 的 file(COPY) 能找到源即可。
TEST_DATA_DIR="$OB_DIR/unittest/sql/engine/op_tests/test_data"
mkdir -p "$TEST_DATA_DIR"
: > "$TEST_DATA_DIR/.keep"
echo "  补齐缺失目录: unittest/sql/engine/op_tests/test_data (占位)"

# ---------- 5. Ubuntu 26 适配补丁 ----------
# 内容: 4 处去 -Werror + 9 处 strchr/strrchr 加 (char *) 强转
cat > "$PATCH_FILE" <<'PATCH_EOF'
diff --git a/deps/easy/CMakeLists.txt b/deps/easy/CMakeLists.txt
index 851f9980..04ae67f0 100644
--- a/deps/easy/CMakeLists.txt
+++ b/deps/easy/CMakeLists.txt
@@ -48,7 +48,7 @@ target_compile_options(easy_base
   INTERFACE
   -D_GLIBCXX_USE_CXX11_ABI=0 -D_GNU_SOURCE -D__STDC_LIMIT_MACROS
   ${MARCH_CFLAGS} ${MTUNE_CFLAGS}
-  $<$<COMPILE_LANGUAGE:C>:-g -Wall -Werror -fPIC ${EASY_CC_WNO}>
+  $<$<COMPILE_LANGUAGE:C>:-g -Wall  -fPIC ${EASY_CC_WNO}>
 )
 
 target_link_libraries(easy_base
diff --git a/deps/easy/src/io/easy_ssl.c b/deps/easy/src/io/easy_ssl.c
index f0d8efe6..ef6abc8a 100644
--- a/deps/easy/src/io/easy_ssl.c
+++ b/deps/easy/src/io/easy_ssl.c
@@ -807,7 +807,7 @@ easy_ssl_t *easy_ssl_config_load(char *filename)
 
         // status
         if (status == 0) {
-            end = strchr(p, '{');
+            end = (char *)strchr(p, '{');
 
             if (end) {
                 *end = '\0';
@@ -826,7 +826,7 @@ easy_ssl_t *easy_ssl_config_load(char *filename)
                 ss->type = (strncmp(p, "client", 6) == 0 ? 1 : 0);
             }
         } else {
-            end = strchr(p, '}');
+            end = (char *)strchr(p, '}');
 
             if (end) {
                 *end = '\0';
@@ -837,7 +837,7 @@ easy_ssl_t *easy_ssl_config_load(char *filename)
                 }
             }
 
-            end = strrchr(p, ';');
+            end = (char *)strrchr(p, ';');
 
             if (!end) {
                 if (status == 0) continue;
@@ -847,7 +847,7 @@ easy_ssl_t *easy_ssl_config_load(char *filename)
             }
 
             *end = '\0';
-            value = strchr(p, ' ');
+            value = (char *)strchr(p, ' ');
 
             if (!value) {
                 easy_error_log("Line %d at %s Error", line, filename);
@@ -1374,7 +1374,7 @@ int easy_ssl_servername(SSL *ssl_conn, int *ad, void *arg)
         return SSL_TLSEXT_ERR_NOACK;
     }
 
-    if ((p = strchr(servername, ':')) != NULL) {
+    if ((p = (char *)strchr(servername, ':')) != NULL) {
         len = p - servername;
     }
 
@@ -1500,7 +1500,7 @@ static int easy_ssl_server_create(easy_ssl_t *ssl, easy_ssl_ctx_t *ss)
     p = ss->conf.server_name;
 
     while(p && *p) {
-        if ((q = strchr(p, ' ')) != NULL)
+        if ((q = (char *)strchr(p, ' ')) != NULL)
             * q = '\0';
 
         key = easy_hash_code(p, strlen(p), 3);
diff --git a/deps/easy/src/util/easy_inet.c b/deps/easy/src/util/easy_inet.c
index 18659b11..d4f90299 100644
--- a/deps/easy/src/util/easy_inet.c
+++ b/deps/easy/src/util/easy_inet.c
@@ -46,12 +46,12 @@ easy_addr_t easy_inet_str_to_addr(const char *host, int port)
     memset(&address, 0, sizeof(easy_addr_t));
 
     if (host) {
-        if (*host == '[' && (p = strchr(host, ']')) != NULL) {
+        if (*host == '[' && (p = (char *)strchr(host, ']')) != NULL) {
             host ++;
             len = p - host;
             p = (*(p + 1) == ':') ? (p + 2) : NULL;
             ipv6 = 0x10000;
-        } else if ((p = strchr(host, ':')) != NULL && (p == strrchr(host, ':'))) {
+        } else if ((p = (char *)strchr(host, ':')) != NULL && (p == (char *)strrchr(host, ':'))) {
             len = p - host;
             p ++;
         }
diff --git a/deps/oblib/src/CMakeLists.txt b/deps/oblib/src/CMakeLists.txt
index 66e37cc0..0b69f63e 100644
--- a/deps/oblib/src/CMakeLists.txt
+++ b/deps/oblib/src/CMakeLists.txt
@@ -148,7 +148,7 @@ if (OB_USE_CLANG)
   set(OBLIB_COMPILE_DEFINITIONS -fno-strict-aliasing -fno-omit-frame-pointer ${MARCH_CFLAGS} ${MTUNE_CFLAGS}
     -D__STDC_LIMIT_MACROS -D__STDC_CONSTANT_MACROS -D_NO_EXCEPTION
     -DOCI_LINK_RUNTIME
-    -Wall -Wextra -Wformat -Werror
+    -Wall -Wextra -Wformat 
     -Wno-deprecated -Wno-address-of-packed-member -Wno-sign-compare -Wno-tautological-compare
     -Wno-psabi -Wno-c99-designator -Wno-int-in-bool-context -Wno-sizeof-array-div
     -Wno-implicit-const-int-float-conversion -Wno-fortify-source -Wno-non-c-typedef-for-linkage
@@ -201,7 +201,7 @@ else()
     -fno-strict-aliasing -fno-omit-frame-pointer ${MARCH_CFLAGS} ${MTUNE_CFLAGS}
     -D__STDC_LIMIT_MACROS -D__STDC_CONSTANT_MACROS -D_NO_EXCEPTION
     -DOCI_LINK_RUNTIME
-    -Wall -Wextra -Wformat -Werror
+    -Wall -Wextra -Wformat 
     -Wno-deprecated
     -Wno-sign-compare
     -Wno-psabi
diff --git a/src/logservice/libobcdc/src/CMakeLists.txt b/src/logservice/libobcdc/src/CMakeLists.txt
index d13dd52f..8a2696a4 100644
--- a/src/logservice/libobcdc/src/CMakeLists.txt
+++ b/src/logservice/libobcdc/src/CMakeLists.txt
@@ -153,7 +153,7 @@ target_compile_definitions(obcdc_objects PRIVATE ENABLE_DEBUG_LOG)
 if (OB_STRICT_COMPILE_FLAGS)
   target_compile_options(obcdc_objects PRIVATE)
 else()
-  target_compile_options(obcdc_objects PRIVATE -Werror)
+  target_compile_options(obcdc_objects PRIVATE )
 endif()
 if (OB_SO_CACHE)
   add_library(obcdc SHARED IMPORTED GLOBAL)
PATCH_EOF

fix_strchr() {   # 幂等: 已经强转过就不再处理
  local f="$1"
  [[ -f "$f" ]] || return 0
  if grep -q '(char \*)strchr' "$f"; then echo "    已强转, 跳过: $f"; return 0; fi
  perl -pi -e 's/(=|==)\s*(strchr|strrchr)\(/$1 (char *)$2(/g' "$f"
  echo "    已加强转: $f"
}

log "应用 Ubuntu 26 适配补丁"
if git -C "$OB_DIR" apply --3way --ignore-whitespace "$PATCH_FILE" 2>/dev/null; then
  echo "  → 方式: git apply (补丁精确命中)"
else
  warn "补丁上下文不匹配(版本已变动), 改用等价替换"
  for f in deps/easy/CMakeLists.txt deps/oblib/src/CMakeLists.txt src/logservice/libobcdc/src/CMakeLists.txt; do
    [[ -f "$OB_DIR/$f" ]] && perl -pi -e 's/(^|\s)-Werror\b/$1/g' "$OB_DIR/$f" && echo "    去 -Werror: $f"
  done
  fix_strchr "$OB_DIR/deps/easy/src/io/easy_ssl.c"
  fix_strchr "$OB_DIR/deps/easy/src/util/easy_inet.c"
fi

# 校验: 三处 CMakeLists 不应再有 -Werror
for f in deps/easy/CMakeLists.txt deps/oblib/src/CMakeLists.txt src/logservice/libobcdc/src/CMakeLists.txt; do
  if grep -q -- '-Werror' "$OB_DIR/$f" 2>/dev/null; then
    die "$f 仍有 -Werror 残留, 补丁未生效"
  fi
done
echo "  补丁校验通过"

# ---------- 6. OceanBase 自带工具链 (clang 17 等) ----------
log "拉取自带 devtools 工具链 (./build.sh init)"
( cd "$OB_DIR" && bash ./build.sh init ) || warn "init 返回非 0, 继续尝试编译"

# ---------- 6.5 Ubuntu 26 兼容: devtools 工具链需要 OpenSSL 1.1 ----------
# build.sh 硬编码 CMAKE_COMMAND=${TOOLS_DIR}/bin/cmake，该二进制链接
# libssl.so.1.1 / libcrypto.so.1.1；Ubuntu 26.04 只有 OpenSSL 3，直接跑会报
# "error while loading shared libraries: libssl.so.1.1" → Failed to generate Makefile。
# 双保险：a) 从 Ubuntu focal 解出 libssl1.1 给整个工具链用；
#        b) 若仍跑不起来，把 cmake 换成系统 cmake 的 wrapper
#           (build.sh release 不带 --init，之后不会覆盖 devtools)。
log "补 OpenSSL 1.1 兼容库 (Ubuntu focal libssl1.1)"
SSL11_DIR="$OUT_DIR/ssl11"
mkdir -p "$SSL11_DIR"
SSL11_DEB="$OUT_DIR/libssl1.1.deb"
if [[ ! -f "$SSL11_DIR/usr/lib/x86_64-linux-gnu/libssl.so.1.1" ]]; then
  curl -fsSL --retry 3 --max-time 120 -o "$SSL11_DEB" \
    "http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2.24_amd64.deb" \
    || die "下载 libssl1.1 失败"
  dpkg-deb -x "$SSL11_DEB" "$SSL11_DIR" || die "解包 libssl1.1 失败"
fi
export LD_LIBRARY_PATH="$SSL11_DIR/usr/lib/x86_64-linux-gnu${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
ls -l "$SSL11_DIR/usr/lib/x86_64-linux-gnu/"

DEVTOOLS_BIN="$OB_DIR/deps/3rd/usr/local/oceanbase/devtools/bin"
if [[ -d "$DEVTOOLS_BIN" ]] && ! "$DEVTOOLS_BIN/cmake" --version >/dev/null 2>&1; then
  mv -f "$DEVTOOLS_BIN/cmake" "$DEVTOOLS_BIN/cmake.orig"
  cat > "$DEVTOOLS_BIN/cmake" <<'WRAPPER_EOF'
#!/usr/bin/env bash
exec /usr/bin/cmake "$@"
WRAPPER_EOF
  chmod +x "$DEVTOOLS_BIN/cmake"
  echo "  → devtools cmake 已替换为系统 cmake wrapper"
fi
"$DEVTOOLS_BIN/cmake" --version | head -1 || die "cmake 仍不可用"

# ---------- 7. 编译 ----------
log "开始编译: build.sh release --make -j${JOBS}   (日志: $LOG)"
START=$(date +%s)
set +e
( cd "$OB_DIR" && bash ./build.sh release --make -j"${JOBS}" ) > "$LOG" 2>&1
BUILD_EXIT=$?
set -e
END=$(date +%s)
ELAPSED=$(( END - START ))
echo "BUILD_START=$(date '+%F %T')" > "$TIME_FILE"
echo "ELAPSED_SEC=$ELAPSED" >> "$TIME_FILE"
echo "ELAPSED_HMS=$(printf '%02d:%02d:%02d' $((ELAPSED/3600)) $((ELAPSED%3600/60)) $((ELAPSED%60)))" >> "$TIME_FILE"
echo "BUILD_EXIT=$BUILD_EXIT" >> "$TIME_FILE"
echo "JOBS=$JOBS" >> "$TIME_FILE"
echo "COMMIT=$OB_COMMIT" >> "$TIME_FILE"
cat "$TIME_FILE"

# ---------- 8. 产物校验 ----------
OBSERVER="$OB_DIR/build_release/src/observer/observer"
if [[ -f "$OBSERVER" ]]; then
  log "编译成功 ✅   耗时 $(printf '%02d:%02d:%02d' $((ELAPSED/3600)) $((ELAPSED%3600/60)) $((ELAPSED%60)))"
  ls -lh "$OBSERVER"
  ls -lh "$OB_DIR/build_release/src/observer/liboceanbase.so" 2>/dev/null || true
  file "$OBSERVER" 2>/dev/null | cut -c1-200 || true
  du -sh "$OB_DIR" 2>/dev/null || true
  ART_DIR="$(pwd)/_oceanbase_build/artifacts"
  mkdir -p "$ART_DIR"
  {
      echo "project=oceanbase/oceanbase"
      echo "commit=$OB_COMMIT"
      echo "elapsed_sec=$ELAPSED"
      echo "jobs=$JOBS"
      echo "observer_bytes=$(stat -c '%s' "$OBSERVER" 2>/dev/null || echo unknown)"
  } >"$ART_DIR/build-info.txt"
  cp "$TIME_FILE" "$ART_DIR/ob-build.time" 2>/dev/null || true
  echo "PASS: 产物清单写入 $ART_DIR"
  exit 0
fi

log "编译失败 ❌ (exit=$BUILD_EXIT), 日志最后 40 行:"
tail -40 "$LOG" || true
exit "$BUILD_EXIT"
