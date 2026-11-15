# nginx 源码构建说明（`c/nginx_v/linux/latest` 与 `c/nginx_v/linux/1_30_6`）

## 版本依据（2026-10-24 实测）

| 项 | 值 | 来源 |
| --- | --- | --- |
| Stable | `1.30.6` | `curl https://nginx.org/en/download.html`，“Stable version” 小节里的 `nginx-x.y.z` |
| Mainline | `1.31.8` | 同页 “Mainline version” 小节 |
| `latest` 分支实际取到的版本 | `1.31.8` | 脚本取页面上所有 `nginx-x.y.z.tar.gz` 的最大值；本地对下载到的 `download.html` 跑同一段解析，输出 `0.5.38 … 1.30.6 1.31.8`，末位即 `1.31.8` |
| `nginx-1.30.6.tar.gz` sha256 | `3cf46f5ed7504d460125866b7bea99fb357f31d887e2e63b35503310e9b8b6c8` | 本地从 nginx.org 下载后 `sha256sum` |
| `nginx-1.31.8.tar.gz` sha256 | `0652b760b3b772d2ec17b47c2fc15d9a95e6fe35cd5b877eadc1a62d9bc75af1` | 同上 |
| PCRE 8.45 sha256 | `4e6ce03e0336e8b4a3d6c2b70b1c5e18590a5673a98186da90d4f33c23defc09` | sourceforge 镜像下载后 `sha256sum`（`https://ftp.pcre.org` 直连时本地证书异常，故以能取到的镜像为准） |

PGP：nginx.org 确实发布了 `nginx-1.30.6.tar.gz.asc`，本地 `gpg --verify` 读到的签名信息是
`Signature made Fri Oct 2 22:40:20 2026 / RSA key D6786CE303D9A9022998DC6CC8464D549AF75C0A / issuer s.kandaurov@f5.com`，
但 `keys.openpgp.org` 上 `--recv-keys` 返回 “No data”，所以**本脚本没完成验签**，只钉了 sha256。
这是明确没做到的一项，不要当成已验证。

## 与旧脚本的关系

同一分支上原来的 `get_nginx.sh`（`nginx-1.8.1`，2014 年的包，`sudo make install` 装到 `/usr/local/nginx`，
无任何运行期校验）**原样保留、不改写**。本文件配套的 `build_nginx.sh` 是新入口，
workflow 从调用 `get_nginx.sh` 改成调用 `build_nginx.sh`，同时把 `runs-on` 从
`ubuntu-20.04` 换到 `ubuntu-24.04` —— 旧标签在 GitHub 上已下线，
证据是 2026-09-18 的两次 run（`35380490923`、`35377913628`）都停在 cancelled，
2026-10-24 重新从 main 触发（`40044005648`）依旧进不了 running，一直在 queued。
`1.8.1` 本身在 Ubuntu 24.04 的 OpenSSL 3 下也编不过，这也是不换版本只换 runner 行不通的原因。

## 构建步骤

1. `apt` 装 `build-essential zlib1g-dev libssl-dev libpcre3 libpcre3-dev openssl wget curl`。
2. 定版本：`1_30_6` 分支由 workflow 传 `NGINX_VERSION=1.30.6` 钉死 Stable；
   `latest` 分支不传，脚本把 `download.html` 上出现的 `nginx-x.y.z.tar.gz` 全列出来 `sort -V` 取最大，
   即当前最新发布版（实测 1.31.8，mainline 线），两条分支合起来覆盖 Stable + Mainline。
3. 下载 tarball，`sha256sum -c` 对表；版本在表外时只记录 hash 并 WARN（便于将来升级时把新 hash 填进表）。
4. 校验源码内版本：`src/core/nginx.h` 里的 `NGINX_VERSION` 必须等于目标版本。
5. PCRE 后端探测：有 `/usr/include/pcre.h` 就交给系统库（`--with-pcre-jit`）；
   没有就退到 nginx 的 `--with-pcre=<pcre-8.45 源码目录>` 自带编译，两条路都钉 hash。
   ~~nginx 只用 PCRE1 的 API，所以这里不能换成 libpcre2。~~ —— 这句是我写错了，实测打脸：
   ubuntu-24.04 runner 上走的是系统这条路（`configure arguments` 里只有 `--with-pcre-jit`，
   没有 `--with-pcre=`），而 `ldd` 出来的却是 `libpcre2-8.so.0`（见 run `40045788270`），
   说明现在 nginx 默认链的是 PCRE2。CI 里被真正执行过的只有“系统库”这条路，
   自带 PCRE 8.45 的兜底分支在这条流水线上没被触发过，只能算留着备用的写法。
6. `./configure` 全部路径落在工作区 `out/nginx`，不碰系统目录、不需要 sudo；
   模块：`http_ssl`、`http_v2`、`http_stub_status`、`http_gzip_static`、`http_realip`、`http_sub`、`--with-threads`。
7. `make -j$(nproc)` + `make install`。

## 验证清单（脚本逐条 assert）

- `nginx -v` / `nginx -V`：版本串含目标版本；`-V` 里必须出现上面 4 个 `--with-http_*_module`，缺一个就 FATAL。
- `file` / `ldd` / `du`：确认是本机 ELF、链接的是系统 `libssl`。
- 生成自签证书（`openssl req -x509`），写一份测试配置（HTTP 18080 / HTTPS 18443 + `http2 on`）。
- `nginx -t` 配置语法检查通过。
- 真启动 → `GET http://127.0.0.1:18080/` = 200 且正文含 “Welcome to nginx”。
- `GET /stub_status` 返回 “Active connections”。
- `gzip_static`：预置 `static.txt.gz` 并删掉明文，带 `Accept-Encoding: gzip` 请求必须 200 且响应头有
  `content-encoding: gzip`，`zcat` 出来的内容要和写入时一致。
- HTTPS：`curl -k https://…` = 200；`--http2-prior-knowledge` 时 `http_version` 必须是 2；
  再用 `openssl s_client` 打印实际协商的 Protocol/Cipher（含一次 `-tls1_2` 回退）。
- `nginx -s reload` 后再请求仍 200；`nginx -s quit` 后端口应释放。

## 没做的事

- 没做 PGP 验签（原因见上）。
- 没跑官方 `test-nginx`/`nginx-tests` 套件：那需要 Perl + 一堆可选模块 + 外部服务，不在本分支范围。
- 没验证 realip 模块的实际改写效果（需要代理链路），只保证被编译进去。

## CI 实测记录

| 轮次 | run | 分支 | 结果 | 说明 |
| --- | --- | --- | --- | --- |
| 1 | `40045788270` | `c/nginx_v/linux/1_30_6` | failure | 下载、configure、make、`make install`、`nginx -V` 全过了，卡在断言本身：`grep -F "$m"` 里 `$m` 是 `--with-http_ssl_module`，以 `--` 开头被 grep 当成自己的选项，报 `unrecognized option` 后脚本判 FATAL。修法是 `grep -F -- "$m"`。 |
| 1 | `40045793619` | `c/nginx_v/linux/latest` | failure | 同一个 grep 问题；另外暴露出自动探测取的是 **1.31.8**，不是我以为的 Stable。原因是 nginx.org 这一页整个是**单行 HTML**，`awk '/Stable version/{f=1} ...'` 一命中就锁定了整行，`match()` 只能拿到行内第一个 `nginx-x.y.z`，也就是 Mainline。现已改成“列出全部 tarball 版本取最大”，并在 workflow 注释里写明 latest 跟的是最新发布线。 |
| 2 | `40046892857`（1_30_6 分支）、`40046880180`（latest 分支） | 两条 | success | 钉定线：`使用钉定版本：1.30.6` → hash 一致 → `nginx/1.30.6`；滚动线：解析出 21 个 tarball 版本并取到 `1.31.8`。两边都跑完同一套运行期断言：4 个 `--with-http_*_module` 全 PASS，`GET /` 200 + “Welcome to nginx”，`stub_status` 有 “Active connections”，`gzip_static` 200 + `content-encoding: gzip` + `zcat` 内容一致，HTTPS 200 且 `HTTP/2 协商结果: 2`，`openssl s_client` 实测 TLSv1.3（`TLS_AES_256_GCM_SHA384`）与强制 `-tls1_2`（`ECDHE-RSA-AES256-GCM-SHA384`），`reload` 后仍 200，`quit` 后端口释放。 |

第 3 轮把 main 聚合后的副本也各触发了一次：`40047457295`（nginx 1_30_6）、`40047459738`（nginx latest），都是 success，说明 main 上那份 workflow 的字面量分支 pin 和 ubuntu-24.04 一起可用。
