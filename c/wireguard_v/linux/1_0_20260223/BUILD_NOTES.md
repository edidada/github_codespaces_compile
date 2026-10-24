# wireguard-tools 1.0.20260223 构建说明

## 版本依据（都是当场量的，不是猜的）

| 项 | 值 | 怎么得到的 |
| --- | --- | --- |
| 上游 tag | `v1.0.20260223` | `gh api repos/WireGuard/wireguard-tools/tags` 列表第一项（2026-10-24） |
| zx2c4 snapshot 包 | `wireguard-tools-1.0.20260223.tar.xz` | 直接 `curl https://git.zx2c4.com/wireguard-tools/snapshot/...`，HTTP 200 |
| snapshot sha256 | `af459827b80bfd31b83b08077f4b5843acb7d18ad9a33a2ef532d3090f291fbf` | 本地下载后 `sha256sum` 实测 |
| GitHub archive 包 | `v1.0.20260223.tar.gz` | `curl .../archive/refs/tags/v1.0.20260223.tar.gz`，HTTP 200 |
| GitHub archive sha256 | `859f8af03702db5e5c43f8ece77f5ebef40a2f4627c3e03997a031d4940ea9bc` | 同上；注意两者字节内容不同（发布归档 vs git 打包），所以分开钉 hash |

## 为什么这个分支编译的是用户态工具

WireGuard 的数据面（Curve25519 + AES-256-GCM/ChaCha20-Poly1305 的隧道加解密）自 Linux 5.6 起在内核里，
独立可编译的仓库是 `wireguard-linux-compat`（给老内核出 `wireguard.ko`）和这里的 `wireguard-tools`。
托管 runner 上装内核模块、`insmod`、真起隧道都不现实（内核版本由宿主控制，也没有网络命名空间外的出口），
所以本分支产出的就是官方的 `wg` / `wg-quick`：内核数据面的配置接口，本身包含完整的密钥运算实现
（`src/curve25519.c` + `curve25519-hacl64.h` / `curve25519-fiat32.h`），可以真刀真枪地验证。

推断部分（未在本分支证伪）：`wireguard-linux-compat` 想在 runner 上编译需要 `/lib/modules/$(uname -r)/build`，
托管镜像里是否带对应 headers 不确定；真要编译内核模块应在带 headers 的自建 runner 上做。

## 构建步骤

1. `apt` 装 `build-essential iproute2 pkg-config xz-utils`。
2. 下载 snapshot 包，失败则退回 GitHub archive 包；两条路径各自 `sha256sum -c`。
3. `make -C src -j$(nproc)`。注意：仓库**没有顶层 Makefile**，入口是 `src/Makefile`（默认目标 `all -> wg`）。
4. `make -C src install PREFIX=/usr-local DESTDIR=$WORK_DIR/out WITH_WGQUICK=yes WITH_BASHCOMPLETION=yes`。
   `Makefile` 用 “`$(BINDIR)/bash` 是否存在” 来自动决定是否安装 `wg-quick`，装到临时 PREFIX 时探测不到，
   所以要显式传 `WITH_WGQUICK=yes`（这是读 `src/Makefile` 得到的，不是猜的）。
5. 版本号来源：`src/Makefile` 先试 `git describe`，tarball 里没有 `.git`，于是走 `src/version.h` 的
   `#define WIREGUARD_TOOLS_VERSION "1.0.20260223"` 兜底 —— 所以 `wg --version` 应当含该版本号。

## 验证清单（脚本里逐条 assert，失败即 FATAL）

- `wg --version` 含 `1.0.20260223`。
- `file` / `ldd` 看产物确实是本机 ELF、依赖正常。
- `wg genkey`：输出 44 字符 base64、解码 32 字节；再按 Curve25519 规定检查位约束
  （`b[0] & 7 == 0`、`b[31] & 0xE0 == 0x40`）。
- `wg pubkey` 对同一私钥两次结果一致（确定性）。
- **交叉验证**：脚本内嵌一份纯 Python 的 X25519 montgomery ladder，
  先用 RFC 7748 §5.1 的权威向量自检（Alice 私钥 `77076d0a…` → 公钥 `8520f009…`，
  与 Bob 公钥 `de9edb7d…` 的共享密钥 `4a5d9d5b…`；这三个值 2026-10-24 从 RFC 原文取，
  并在本地用同一份实现复现通过），再断言它算出的公钥 == 编译出的 `wg` 给出的公钥。
  两个实现互相独立（Python 大数 vs wg 的 fiat/hacl 汇编级 C），一致才算通过。
- 输入校验：43 字符的残缺 base64 必须被 `wg pubkey` 拒绝。
- `wg-quick` 已安装且 `bash -n` 语法检查通过。
- live 测试：尝试 `modprobe wireguard` + `ip link add dev wg0 type wireguard`，成功则
  跑 `wg set` / `wg show` / `wg showconf` / `wg syncconf` 全链路并删除网口；
  内核没模块时打印 `SKIP` 并说明原因，不假装成功。

## 没做的事

- 不装到系统目录（`DESTDIR` 隔离在工作区）。
- 不验证真实隧道转发：托管 runner 上没有对端，也没有可路由的第二张网卡。
- 没做上游 PGP/minisign 验签：脚本钉的是 sha256，取法见上表；上游确实提供 `.minisig`，
  要加验签需要引入 minisign 并固定公钥，本分支未做。

## CI 实测记录

| 轮次 | run | 结果 | 说明 |
| --- | --- | --- | --- |
| 1 | `40045782760` | failure | 用户态那 10 步全绿：源码包 sha256 命中、`make -C src` 编过、`install` 带 `WITH_WGQUICK=yes` 装了 wg/wg-quick/completion/systemd 单元、`wg --version` = `wireguard-tools v1.0.20260223`、genkey 位约束、纯 Python X25519 复现 RFC 7748 5.1 向量且与 `wg pubkey` 一致、残缺 base64 被拒、`bash -n wg-quick` 通过。翻车在最后一步 live 测试：我给 `wg set` 传了 `address 10.188.188.1/24`，报 `Invalid argument: address` 后 `set -e` 直接退出。查了 `src/config.c` 的参数解析分支（`listen-port / fwmark / private-key / peer / remove / endpoint / allowed-ips / persistent-keepalive / preshared-key`）里根本没有 `address`，`src/man/wg.8` 也明说 “their IP addresses and routing tables can be set using ip-address(8) and ip-route(8)” —— 这个选项是早年间内核 `add_device` 那条路上的东西，现在归 iproute2 管。第二轮改成 `ip addr add … dev wg0`，并把 SKIP 判据从 modprobe 换成“能不能真的建出 wg0”（内置模块时 modprobe 会失败但建网口没问题）。 |
| 2 | 待补 |  |  |
