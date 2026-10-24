# glibc 源码构建说明（`c/glibc_v/linux/latest`）

## 这次改了什么

workflow 侧只把 `runs-on` 从 `ubuntu-20.04` 换成 `ubuntu-latest`（ubuntu-20.04 镜像在
GitHub 已下线，job 永远进不了 running：2026-09-18 的 35380490923 / 35377913628 停在
cancelled，2026-10-24 从 main 重新触发的 40044005648 一直 queued）。换成最新镜像后
job 真的开始跑了，然后旧脚本在 run 40056354217 里失败，根因是**编译器版本**，不是标签。

失败输出（`gh run view 40056354217 --log-failed` 实测）：

```
In file included from ../include/setjmp.h:2,
                 from ../nptl/descr.h:24:
../setjmp/setjmp.h:54:46: note: previously declared as an array 'struct __jmp_buf_tag[1]'
   54 | extern int __sigsetjmp (struct __jmp_buf_tag __env[1], int __savemask) __THROWNL;
cc1: all warnings being treated as errors
subprocess.CalledProcessError: Command 'gcc -std=gnu11 ... -Werror ... -S -o /tmp/.../test.s -x c -' returned non-zero exit status 1.
make[2]: *** [../Makerules:271: .../glibc-2.29/build/tcb-offsets.h] Error 1
./c/glibc_v/linux/latest/get_glibc.sh: line 14: /opt/glibc-2.29/lib/ld-linux-x86-64.so.2: No such file or directory
```

`-Warray-parameter` 是 gcc 13 新增的诊断，ubuntu-24.04 的默认 gcc 就是 13.x，glibc 2.29
（2019-02 的 release）里那处声明不一致于是被 `-Werror` 判死，连 `tcb-offsets.h` 都生成不出来。

## 版本依据（2026-10-24 实测）

| 项 | 值 | 来源 |
| --- | --- | --- |
| latest | `2.44`（脚本运行时现算，取列表里 `sort -V` 的最大值） | `curl https://ftp.gnu.org/gnu/glibc/` 解析 `glibc-x.y.tar.gz`；当天末尾 5 个候选是 2.40/2.41/2.42/2.43/2.44 |
| Mainline/Stable 语义 | 本分支跟“最新正式 release”，和 `c/nginx_v/linux/latest` 同一套约定 | — |
| 签名者 key | `FD19E6D31B192EE4DC63EAD3DC2B16215ED5412A`（keyid `DC2B16215ED5412A`） | 本地 `gpg --list-packets glibc-2.44.tar.gz.sig`，sig 创建时间 2026-07-25 |
| 该指纹归属 | 主钥 `35B17DF5752577CA0C541CEB94BFDF4484AD142F`，uid `Andreas K. Huettel <mail@akhuettel.de>` | `curl https://keys.openpgp.org/vks/v1/by-fingerprint/<指纹>` 与 keyserver.ubuntu.com 各取一次，两份 blob 里都能 `grep` 到该 keyid |

## 脚本步骤

1. `apt` 装 `build-essential gawk bison texinfo python3 file`。**去掉了旧的 `apt-get upgrade`**：
   它只会升级 runner 自己的 libc6，对构建没好处。
2. 解析 `ftp.gnu.org/gnu/glibc/` 目录列表，`sort -uV` 取最大版本（不写死）。
3. 下载 tarball + `.sig`；`sha512sum` 记录摘要（GNU 侧不发布 `.sha512` 文本，所以只能记录、
   不能“对表”）。
4. 尽力 PGP 验签：`gpg --recv-keys <指纹>` 后 `gpg --verify`。取不到公钥 → WARN 继续；
   验签返回 0 但日志里没有 `Good signature` → FATAL。
5. `../configure --prefix=/opt/glibc-<V> --disable-werror` → `make -j$(nproc)` → `sudo make install`。
6. 校验：`ld.so --version` 必须含目标版本号；再用**新编出来的 loader + libc** 跑一个用系统 gcc
   编的探针（`gnu_get_libc_version()` 返回的是实际加载的那份 libc 的版本），断言输出等于目标版本；
   最后打印 `/lib/x86_64-linux-gnu/libc.so.6` 和 `ldd /bin/ls`，证明系统 libc 没被替换。

## 没做的事 / 已知边界

- **没建立 PGP 信任链**：只验证“签名由那把公钥做出”，没有 web-of-trust 或 tofu 佐证该公钥确实是
  GNU 指定的 glibc 维护者密钥。而且 GNU 不发布 `.sha512` 文本，所以拿不到公钥时完整性只能靠 HTTPS
  传输 + 记录摘要。
- 没跑 glibc 的 `make check` 测试套件（上万个用例、需要额外依赖，且不能拿新建的 glibc 直接替换
  系统 libc 来跑）。
- `--disable-werror` 是全局降级：真正的 error 仍然会失败，但新编译器引入的告警不再阻断构建。
