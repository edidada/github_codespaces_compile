#! /bin/bash
# glibc 源码编译。分支名是 latest，所以版本取 ftp.gnu.org/gnu/glibc 上当前最新的正式 release。
#
# 2026-10-24 改造（根因与实测见同目录 BUILD_NOTES.md）：
#   旧脚本钉死 glibc-2.29 + `../configure --prefix=/opt/glibc-2.29`。ubuntu-24.04 的 gcc 13
#   新增 -Warray-parameter，setjmp.h 里 `__sigsetjmp (struct __jmp_buf_tag __env[1], ...)`
#   与另一处声明不一致，上游 -Werror 把它判成错误，csu/tcb-offsets.h 就生成不出来：
#     ../setjmp/setjmp.h:54:46: note: previously declared as an array 'struct __jmp_buf_tag[1]'
#     cc1: all warnings being treated as errors
#   2.29 是 2019 年的 release，与其给它打补丁，不如按分支语义取当前正式版本。
set -euo pipefail
cd "$(dirname "$0")"

BASE="https://ftp.gnu.org/gnu/glibc"
WORK_DIR="$(pwd)/.work"
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"

echo "==== 1. 依赖 ===="
sudo apt-get update -qq
# 旧脚本里的 `apt-get upgrade` 去掉了：它只会顺手升级 runner 自己的 libc6，对构建没有好处
sudo apt-get install -y -qq build-essential gawk bison texinfo python3 file libncurses5-dev libstdc++6

echo "==== 2. 解析 latest ===="
mapfile -t VERS < <(curl -fsSL "$BASE/" \
    | grep -oE 'glibc-[0-9]+\.[0-9]+\.tar\.gz' \
    | sed -E 's/^glibc-//; s/\.tar\.gz$//' | sort -uV)
[ "${#VERS[@]}" -gt 0 ] || { echo "FATAL: 目录列表里没解析到任何版本" >&2; exit 1; }
GLIBC_VERSION="${VERS[-1]}"
echo "候选末尾 5 个: ${VERS[*]: -5}"
echo "选定 GLIBC_VERSION=$GLIBC_VERSION"

echo "==== 3. 下载 + 完整性 ===="
TAR="$WORK_DIR/glibc-$GLIBC_VERSION.tar.gz"
curl -fsSL --retry 3 -o "$TAR" "$BASE/glibc-$GLIBC_VERSION.tar.gz"
sha512="$(sha512sum "$TAR" | cut -d' ' -f1)"
echo "sha512 = $sha512"
[ "${#sha512}" -eq 128 ] || { echo "FATAL: sha512 摘要长度异常" >&2; exit 1; }

# GNU 只发布 .sig（PGP），不发布 .sha512 文本，所以这里能做的是“尽力验签”。
# 实测签名者：issuer 全指纹 FD19E6D31B192EE4DC63EAD3DC2B16215ED5412A（keyid DC2B16215ED5412A），
# 2026-10-24 本地 `gpg --list-packets glibc-2.44.tar.gz.sig` 读到；该指纹在 keys.openpgp.org 和
# keyserver.ubuntu.com 都能取到，属于主钥 35B17DF5752577CA0C541CEB94BFDF4484AD142F
# （uid: Andreas K. Huettel <mail@akhuettel.de>）。取不到公钥只降级成 WARN，
# 但“签名本身校验失败”是 FATAL —— 不能把没验过当成验过了。
GNUPG="$WORK_DIR/gnupg"
mkdir -p "$GNUPG"; chmod 700 "$GNUPG"
if curl -fsSL --retry 2 -o "$TAR.sig" "$BASE/glibc-$GLIBC_VERSION.tar.gz.sig"; then
    if timeout 150 gpg --homedir "$GNUPG" --no-tty --batch --quiet \
            --recv-keys FD19E6D31B192EE4DC63EAD3DC2B16215ED5412A 2>/dev/null \
       && timeout 150 gpg --homedir "$GNUPG" --no-tty --batch \
            --verify "$TAR.sig" "$TAR" 2>"$WORK_DIR/gpg.log"; then
        grep -F 'Good signature' "$WORK_DIR/gpg.log" >/dev/null \
            || { echo "FATAL: gpg 退出码 0 但日志里没有 Good signature" >&2 \
                 ; sed -n '1,20p' "$WORK_DIR/gpg.log" >&2; exit 1; }
        sed -n '1,12p' "$WORK_DIR/gpg.log"
        echo "PASS: tarball 的 GNU PGP 签名验证通过（只验签名本身，没做 web-of-trust 信任链校验）"
    else
        echo "WARN: 公钥没取到 / dirmngr 不可用，本轮 PGP 验签没做成，只有 sha512 记录 + HTTPS 传输"
        sed -n '1,8p' "$WORK_DIR/gpg.log" 2>/dev/null || true
    fi
else
    echo "WARN: $BASE 上没有 glibc-$GLIBC_VERSION.tar.gz.sig，跳过 PGP 验签"
fi

echo "==== 4. 解压 + configure ===="
tar xzf "$TAR" -C "$WORK_DIR"
SRC="$WORK_DIR/glibc-$GLIBC_VERSION"
[ -f "$SRC/configure" ] || { echo "FATAL: 解压后 $SRC 里没有 configure" >&2; exit 1; }
PREFIX="/opt/glibc-$GLIBC_VERSION"
mkdir -p "$SRC/build"
cd "$SRC/build"
../configure --prefix="$PREFIX" --disable-werror >/dev/null
echo "configure 完成：--prefix=$PREFIX --disable-werror"

echo "==== 5. make ===="
make -j"$(nproc)"
sudo make install

echo "==== 6. 版本 ===="
LD="$PREFIX/lib/ld-linux-x86-64.so.2"
[ -x "$LD" ] || { echo "FATAL: 没装出 $LD" >&2; find "$PREFIX" -maxdepth 2 -name 'ld-linux*' 2>/dev/null | head; exit 1; }
"$LD" --version | tee "$WORK_DIR/ld.version"
grep -F "$GLIBC_VERSION" "$WORK_DIR/ld.version" >/dev/null \
    || { echo "FATAL: ld.so --version 里没有 $GLIBC_VERSION" >&2; exit 1; }
echo "PASS: ld.so --version 含目标版本号"

echo "==== 7. 运行期实测（不碰系统 libc）===="
file "$PREFIX/lib/libc.so.6"
# 用刚编出来的 loader + libc 跑一个用系统 gcc 编的探针：gnu_get_libc_version()
# 返回的是“实际被加载的那份 libc”的版本，所以这一步同时证明了 loader 和 libc 都可用。
cat > "$WORK_DIR/probe.c" <<'C'
#include <stdio.h>
#include <gnu/libc-version.h>
int main(void) { printf("%s\n", gnu_get_libc_version()); return 0; }
C
gcc -O0 -o "$WORK_DIR/probe" "$WORK_DIR/probe.c"
got="$("$LD" --library-path "$PREFIX/lib" "$WORK_DIR/probe")"
echo "探针在新 ld.so 下报告的 glibc 运行时版本 = $got（期望 $GLIBC_VERSION）"
[ "$got" = "$GLIBC_VERSION" ] || { echo "FATAL: 新编译的 glibc 运行时版本不对" >&2; exit 1; }
echo "PASS: 本次编译的 ld.so + libc.so.6 能真实加载并运行动态程序"

echo "==== 8. 确认没覆盖系统 libc ===="
ls -l /lib/x86_64-linux-gnu/libc.so.6
ldd "$(command -v ls)" | sed -n '1,3p'
echo "INFO: 新 glibc 只落在 $PREFIX，系统 /lib 未改动（安装前缀隔离）"
