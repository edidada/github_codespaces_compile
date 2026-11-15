# Tengine 源码构建说明（`c/tengine_v/linux/latest`）

## 这次改了什么

workflow 侧只把 `runs-on` 从 `ubuntu-20.04` 换成 `ubuntu-latest`（该镜像已下线，job 只会一直
queued 到被取消）。换完镜像后 run 40056435654 真的跑起来了，然后旧脚本三处一起暴露：

### 1. apt 包列表在 noble 上整体装不上

同 run 完整日志实测（`gh run view 40056435654 --log`）：

```
E: Package 'initscripts' has no installation candidate
E: Unable to locate package libgd2-xpm-dev
E: Unable to locate package libpcre++0
E: Unable to locate package libpcre++-dev
```

apt 只要有一个包名解析不了就整条命令退出，**所以那一行里列的 libssl-dev / liblua5.1-0-dev 等
一个都没装上**，configure 后面自然报 `checking for PCRE library ... not found`。
另外 `libpcre++-dev` 本身也选错了包：它是 PCRE 的 C++ wrapper，而 nginx/tengine 的 configure
探测的是 C 头 `pcre.h`（在 `libpcre3-dev` 里）。

### 2. `--enable-mods-static=all` 在 3.1.0 里已经不存在

`git clone --depth 1 -b 3.1.0` 后 `grep -n 'mods' auto/options` 无任何命中，而
`auto/options:451` 对未知选项是 `echo "$0: error: invalid option \"$option\""` + 退出，
也就是说这个选项会让 configure 直接失败。`--with-ipv6`（`auto/options:239`）只剩
deprecated 警告，一并去掉。

### 3. tengine-2.2.2 太老

2.2.2（2016 年，基于 nginx 1.8.x）在 OpenSSL 3 下编不过，跟 `c/nginx_v` 那边放弃 1.8.1 是
同一个原因。分支名是 latest，所以按语义取当前正式 release。

## 版本依据（2026-10-24 实测）

| 项 | 值 | 来源 |
| --- | --- | --- |
| latest 正式 release | `3.1.0` | `gh api repos/alibaba/tengine/releases/latest` → `3.1.0  2023-10-27T11:16:27Z` |
| 3.2.0 状态 | 只有 `3.2.0-rc1..rc5` 标签，没有正式 release | `git ls-remote --tags --refs https://github.com/alibaba/tengine.git` |
| 标签形式 | 3.x 是裸版本号 `3.1.0`，2.x 才是 `tengine-2.2.2` | 同上；所以 clone 用 `-b 3.1.0` |
| 内含 nginx 基线 | `NGINX_VERSION "1.24.0"`，`nginx_version 1024000`，`TENGINE_VERSION "3.1.0"` | 3.1.0 源码 `src/core/nginx.h:12,13,18` |
| PCRE | tengine 3.1.0（nginx 1.24 系）优先探测 **PCRE2**（`auto/lib/pcre/conf:10 PCRE_LIBRARY=PCRE2`），`--without-pcre2` 才回退 PCRE1 | 本地 clone 后读 `auto/lib/pcre/conf` |

脚本里 PCRE1 和 PCRE2 的 dev 包都装（`libpcre3-dev libpcre2-dev`），这样不管探测到哪条都能过。

## 验证清单（脚本逐条 assert）

- `src/core/nginx.h` 里 `TENGINE_VERSION` 必须等于 3.1.0，同时打印内含的 nginx 基线版本。
- `nginx -v` 输出里有 `Tengine/3.1.0`；`nginx -V` 里必须出现
  `--with-http_ssl_module`、`--with-http_v2_module`、`--with-http_stub_status_module`、`--with-threads`，缺一个 FATAL。
- `file` / `ldd` 确认是本机 ELF。
- 用工作区里的临时 `-p`/`-c` 配置（监听 18080）跑 `nginx -t` → 真启动 →
  `GET /` 必须 200 且正文含 `Welcome to tengine`（tengine 自己的默认欢迎页，来自 `html/index.html`）。
- `GET /stub_status` 必须返回 `Active connections`。
- `nginx -s reload` 后仍 200；`nginx -s quit` 后端口必须释放。

## 没做的事

- 没验 HTTP/2：`c/nginx_v/linux/1_30_6` 那条已经把 `http2 on` / `openssl s_client` 的协商实测过了，
  这里只保证 `--with-http_v2_module` 被编进去。
- 没编 tengine 自带的扩展模块（ngx_http_lua_module 等）：旧脚本的 `--enable-mods-static=all` 意图是
  “全量静态模块”，但 3.1.0 没有这个开关，逐个 `--add-module` 会把这条老分支的改动量放大很多，
  这里先按 nginx 的核心模块集合走。
- 没跑 tengine 自带的测试套件。
