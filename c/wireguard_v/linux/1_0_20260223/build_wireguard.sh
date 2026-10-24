#!/usr/bin/env bash
#
# WireGuard 用户态工具 wireguard-tools：从源码编译 wg / wg-quick。
#
# 上游：https://git.zx2c4.com/wireguard-tools （官方 GitHub 镜像 WireGuard/wireguard-tools）
# 说明：WireGuard 的数据面（curve25519 + AEZ 加解密）自 Linux 5.6 起在内核里，用户态没有
#       可独立“跑起来”的隧道，所以这个分支编译官方用户态工具链，并用一个独立的纯 Python
#       X25519 实现交叉验证编译出来的 wg 的密钥推导结果。
#
set -euo pipefail

WIREGUARD_TOOLS_VERSION="${WIREGUARD_TOOLS_VERSION:-1.0.20260223}"
SRC_DIR_NAME="wireguard-tools-${WIREGUARD_TOOLS_VERSION}"
SNAPSHOT_TARBALL="${SRC_DIR_NAME}.tar.xz"
GITHUB_TARBALL="v${WIREGUARD_TOOLS_VERSION}.tar.gz"
PRIMARY_URL="https://git.zx2c4.com/wireguard-tools/snapshot/${SNAPSHOT_TARBALL}"
MIRROR_URL="https://github.com/WireGuard/wireguard-tools/archive/refs/tags/v${WIREGUARD_TOOLS_VERSION}.tar.gz"
# 两个来源内容不同（zx2c4 是发布归档 tar.xz，GitHub archive 是 git 打包），所以各自一条 hash。
# 取法：2026-10-24 本地直连两个 URL 下载后 sha256sum 实测得到。
SHA_SNAPSHOT="af459827b80bfd31b83b08077f4b5843acb7d18ad9a33a2ef532d3090f291fbf"
SHA_GITHUB="859f8af03702db5e5c43f8ece77f5ebef40a2f4627c3e03997a031d4940ea9bc"

WORK_DIR="${WORK_DIR:-$(pwd)/_wireguard_build}"
INSTALL_ROOT="${INSTALL_ROOT:-$WORK_DIR/out}"
PREFIX="${PREFIX:-/usr-local}"   # 传给 make 的 PREFIX，实际落在 $INSTALL_ROOT$PREFIX

echo "==== 0. 环境 ===="
uname -a
sed -n '1,4p' /etc/os-release
nproc
echo "目标版本：wireguard-tools ${WIREGUARD_TOOLS_VERSION}"

echo "==== 1. 依赖 ===="
sudo apt-get update -qq
# iproute2：live 段建 wg0 网口要用；pkg-config 影响 Makefile 里 systemd unit 目录探测
sudo apt-get install -y -qq build-essential iproute2 pkg-config xz-utils ca-certificates

echo "==== 2. 下载源码 ===="
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

download_ok=""
if curl -fsSL --connect-timeout 20 --retry 3 --max-time 300 "$PRIMARY_URL" -o "$SNAPSHOT_TARBALL"; then
    download_ok="snapshot"
elif curl -fsSL --connect-timeout 20 --retry 3 --max-time 300 "$MIRROR_URL" -o "$GITHUB_TARBALL"; then
    download_ok="github"
else
    echo "FATAL: 两个上游都下载失败" >&2
    exit 1
fi

if [ "$download_ok" = "snapshot" ]; then
    echo "来源：zx2c4 snapshot（$PRIMARY_URL）"
    printf '%s  %s\n' "$SHA_SNAPSHOT" "$SNAPSHOT_TARBALL" | sha256sum -c -
    tar -xf "$SNAPSHOT_TARBALL"
else
    echo "来源：GitHub archive（$MIRROR_URL）"
    printf '%s  %s\n' "$SHA_GITHUB" "$GITHUB_TARBALL" | sha256sum -c -
    tar -xzf "$GITHUB_TARBALL"
fi

SRC_PATH=""
for cand in "$WORK_DIR/$SRC_DIR_NAME" "$WORK_DIR/wireguard-tools-${WIREGUARD_TOOLS_VERSION}"; do
    [ -d "$cand" ] && SRC_PATH="$cand"
done
[ -n "$SRC_PATH" ] || { echo "FATAL: 解压后找不到源码目录" >&2; ls -1 "$WORK_DIR" >&2; exit 1; }
cd "$SRC_PATH"

echo "==== 3. 源码 ===="
ls -1
echo "version.h 里的版本兜底字符串："
grep -o '"[0-9][0-9.]*"' src/version.h | sed -n '1p'

echo "==== 4. 编译 ===="
# wireguard-tools 没有顶层 Makefile，入口是 src/Makefile（默认目标 all -> wg）
make -C src -j"$(nproc)"
echo "==== 产物 ===="
ls -lh src/wg
file src/wg
ldd src/wg

echo "==== 5. 安装到工作区（DESTDIR 隔离，不需要 sudo） ===="
# Makefile 靠 “$(BINDIR)/bash 是否存在” 自动判断要不要装 wg-quick，装进临时 PREFIX 时探测不到，
# 所以显式打开 WITH_WGQUICK / WITH_BASHCOMPLETION。
make -C src install "PREFIX=$PREFIX" "DESTDIR=$INSTALL_ROOT" WITH_WGQUICK=yes WITH_BASHCOMPLETION=yes
WG="$INSTALL_ROOT$PREFIX/bin/wg"
WGQUICK="$INSTALL_ROOT$PREFIX/bin/wg-quick"
[ -x "$WG" ] || { echo "FATAL: 缺少可执行 $WG" >&2; find "$INSTALL_ROOT" -type f | sed -n '1,20p' >&2; exit 1; }
echo "==== 安装树 ===="
find "$INSTALL_ROOT" -type f | sort | sed -n '1,40p'

echo "==== 6. 版本 ===="
"$WG" --version
"$WG" --version | grep -F "$WIREGUARD_TOOLS_VERSION" \
    || { echo "FATAL: wg --version 里没有 $WIREGUARD_TOOLS_VERSION" >&2; exit 1; }
echo "PASS: wg --version 含目标版本号"

echo "==== 7. genkey 结构与 curve25519 位约束 ===="
priv="$("$WG" genkey)"
echo "wg genkey 输出长度=${#priv}（32 字节 base64 应为 44）"
[ "${#priv}" -eq 44 ] || { echo "FATAL: wg genkey 输出长度异常" >&2; exit 1; }
printf '%s' "$priv" | base64 -d > "$WORK_DIR/priv.bin"
[ "$(stat -c%s "$WORK_DIR/priv.bin")" -eq 32 ] || { echo "FATAL: 私钥解码后不是 32 字节" >&2; exit 1; }
python3 - "$WORK_DIR/priv.bin" <<'PY'
import sys
b = open(sys.argv[1], 'rb').read()
assert b[0] & 0x07 == 0, f"clamp 失败: 最低 3 位未清零 -> {b[0] & 7}"
assert b[31] & 0xE0 == 0x40, f"clamp 失败: 末字节应为 0b01xxxxxx -> {b[31]:#04x}"
print(f"PASS: curve25519 私钥位约束正确 (b[0]={b[0]:#04x} b[31]={b[31]:#04x})")
PY

echo "==== 8. wg pubkey 与独立 X25519 实现交叉验证 ===="
pub_wg1="$(printf '%s' "$priv" | "$WG" pubkey)"
pub_wg2="$(printf '%s' "$priv" | "$WG" pubkey)"
[ "$pub_wg1" = "$pub_wg2" ] || { echo "FATAL: 同一私钥两次推导公钥不一致" >&2; exit 1; }
echo "PASS: 同一私钥两次 wg pubkey 结果一致"
printf '%s' "$pub_wg1" | base64 -d > "$WORK_DIR/pub_wg.bin"
python3 - "$WORK_DIR/priv.bin" "$WORK_DIR/pub_wg.bin" <<'PY'
# 纯 Python X25519（RFC 7748 montgomery ladder），与 wg 里的 fiat/hacl 实现互相独立。
import sys, base64
p = 2**255 - 19
A24 = 121665

def decode_scalar(k):
    n = int.from_bytes(k, 'little')
    n &= ~7
    n &= (1 << 255) - 1
    n |= 1 << 254
    return n

def x25519(k, u):
    k = decode_scalar(k)
    u = int.from_bytes(u, 'little') % p
    x2, z2, x3, z3 = 1, 0, u, 1
    swap = 0
    for t in range(254, -1, -1):
        kt = (k >> t) & 1
        swap ^= kt
        if swap:
            x2, x3 = x3, x2
            z2, z3 = z3, z2
        swap = kt
        a = (x2 + z2) % p
        aa = a * a % p
        b = (x2 - z2) % p
        bb = b * b % p
        e = (aa - bb) % p
        c = (x3 + z3) % p
        d = (x3 - z3) % p
        da = d * a % p
        cb = c * b % p
        x3 = (da + cb) * (da + cb) % p
        z3 = u * (da - cb) * (da - cb) % p
        x2 = aa * bb % p
        z2 = e * (aa + A24 * e) % p
    if swap:
        x2, x3 = x3, x2
        z2, z3 = z3, z2
    return (x2 * pow(z2, p - 2, p) % p).to_bytes(32, 'little')

base9 = (9).to_bytes(32, 'little')
priv = open(sys.argv[1], 'rb').read()
pub_wg = open(sys.argv[2], 'rb').read()
mine = x25519(priv, base9)
print("python 独立推导:", base64.b64encode(mine).decode())
print("编译出的 wg 推导:", base64.b64encode(pub_wg).decode())
assert mine == pub_wg, "两个独立实现结果不一致"
print("PASS: wg pubkey == 独立 X25519(priv, 9)")

# 自检：先用 RFC 7748 §5.1 的权威向量证明这套纯 Python ladder 本身是对的，
# 这样上面“和 wg 一致”才不是两个实现一起错。
ALICE_PRIV = bytes.fromhex('77076d0a7318a57d3c16c17251b26645df4c2f87ebc0992ab177fba51db92c2a')
ALICE_PUB  = bytes.fromhex('8520f0098930a754748b7ddcb43ef75a0dbf3a0d26381af4eba4a98eaa9b4e6a')
BOB_PUB    = bytes.fromhex('de9edb7d7b7dc1b4d35b61c2ece435373f8343c85b78674dadfc7e146f882b4f')
SHARED     = bytes.fromhex('4a5d9d5ba4ce2de1728e3bf480350f25e07e21c947d19e3376f09b3c1e161742')
assert x25519(ALICE_PRIV, base9) == ALICE_PUB, "RFC 7748 5.1 Alice 公钥向量不匹配"
assert x25519(ALICE_PRIV, BOB_PUB) == SHARED, "RFC 7748 5.1 共享密钥向量不匹配"
print("PASS: 本脚本的 X25519 复现了 RFC 7748 5.1 的公钥与共享密钥向量")
PY

echo "==== 9. 非法输入必须被拒绝 ===="
if printf '%s' 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' | "$WG" pubkey >/dev/null 2>&1; then
    echo "FATAL: 43 字符的残缺 base64 竟然被接受了" >&2
    exit 1
fi
echo "PASS: 非法私钥被拒绝"

echo "==== 10. wg-quick ===="
if [ -f "$WGQUICK" ]; then
    bash -n "$WGQUICK" && echo "PASS: wg-quick 语法检查通过"
    echo "wg-quick 行数: $(grep -c . "$WGQUICK")"
else
    echo "WARN: 未安装 wg-quick（WITH_WGQUICK 条件未满足），继续"
fi

echo "==== 11. live 网口测试（runner 内核没有 wireguard 就 SKIP） ===="
LIVE_RESULT=skip
if sudo modprobe wireguard 2>/dev/null || grep -q '^wireguard' /proc/modules; then
    if sudo ip link add dev wg0 type wireguard 2>/dev/null; then
        LIVE_RESULT=ok
        printf '%s' "$priv" > "$WORK_DIR/priv.key"
        peer_pub="$(printf '%s' "$priv" | "$WG" pubkey)"
        sudo "$WG" set wg0 private-key "$WORK_DIR/priv.key" address 10.188.188.1/24 \
            peer "$peer_pub" endpoint 127.0.0.1:51820 allowed-ips 10.188.188.0/24 persistent-keepalive 25
        echo "---- wg show wg0 ----"
        sudo "$WG" show wg0
        echo "---- wg showconf wg0 往返 ----"
        sudo "$WG" showconf wg0 | tee "$WORK_DIR/live.conf"
        sudo "$WG" syncconf wg0 "$WORK_DIR/live.conf"
        sudo "$WG" show wg0 | grep -F 'latest handshake' || echo "（无握手记录，属预期：没有对端）"
        sudo ip link del wg0
        echo "PASS: wg set / show / showconf / syncconf 全链路可用"
    else
        echo "SKIP: ip link add 失败，内核可能不支持 wireguard netdev"
    fi
else
    echo "SKIP: 该 runner 内核没有 wireguard 模块，只做用户态校验"
fi

echo "==== 12. 汇总 ===="
echo "wireguard-tools 版本 : ${WIREGUARD_TOOLS_VERSION}"
echo "下载来源             : ${download_ok}"
echo "wg 路径              : $WG"
echo "wg sha256            : $(sha256sum "$WG" | cut -d' ' -f1)"
echo "live 网口测试        : ${LIVE_RESULT}"
"$WG" --version
echo "完成：wireguard-tools ${WIREGUARD_TOOLS_VERSION} 已从源码构建并通过用户态校验"
