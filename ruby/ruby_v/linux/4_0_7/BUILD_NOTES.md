# ruby v4.0.7（Linux，CRuby 解释器）

## 版本

`v4.0.7`（tag 名就是 `v4.0.7`，带 v 前缀）是 ruby/ruby 当前最新稳定标签，
`gh api repos/ruby/ruby/releases/latest` = v4.0.7（2026-09-15）。tag 列表里 4.0 系列
从 v4.0.0 一路到 v4.0.7，`v4.1.0-preview1` 是预览不算稳定版。这里编的是 CRuby
解释器本体（MRI 3.x/4.x 的 VM），不是 JRuby/TruffleRuby。

## 上游 CI 的构建方式（本脚本照抄）

`.github/workflows/ubuntu.yml` + `.github/actions/setup/{ubuntu,directories}/action.yml`：

1. apt 装：`build-essential autoconf ruby libssl-dev libyaml-dev libreadline6-dev
   zlib1g-dev libncurses5-dev libffi-dev pkg-config`（`ruby` 是 baseruby）。
2. `./autogen.sh --install`（= `autoreconf --install --symlink`）。
3. out-of-source：建 `build` 目录，在里面跑 `../src/configure -C --disable-install-doc`。
4. `GNUMAKEFLAGS=-sj$((1+nproc))` 然后 `make`、`make hello`。

## 关键坑

- **git checkout 必须先 autogen.sh**：ruby 仓库不跟踪 `configure`（它是 autoconf
  生成物）。少了这一步，`../configure` 直接 No such file。这就是上游 apt 里
  要装 `autoconf` 的原因，也是"从源码编译"和"装 deb 包"的差别所在。
- **apt 包名在 noble 上变了**：上游 action 写的是 jammy 时代的
  `libreadline6-dev` / `libncurses5-dev`；Ubuntu 24.04 上对应
  `libreadline-dev` / `libncurses-dev`。脚本装新名字，老名字用 `|| true` 兜一下，
  免得哪天又反过来。
- **out-of-source 的相对路径**：build 目录在 `project/build`，所以 configure
  用 `../configure`（上游是 `../src/configure`，因为它们把源码目录 symlink 成
  `src`）。`-C` 就是 autoconf 的 `--config-cache`。
- **`--disable-install-doc`**：不禁用的话 `make` 会顺带生成整套 rdoc/RI，
  比编译 VM 本身还慢，而且和"能跑的 ruby"无关。上游也关。
- **YJIT 依赖 rustc**：x86_64-linux 上 YJIT 默认开，需要 Rust 工具链。
  GitHub 的 ubuntu runner 预装了 rust，但脚本仍然显式探测：没有 rustc 就传
  `--disable-yjit`，否则 configure 会在 JIT 阶段报错。
- **不需要 bison**：ruby 3.3 之后 `parse.y` 默认走自带的纯 Ruby 生成器
  `tool/lrama`（靠 baseruby 跑），apt 里不装 bison 也能过。
- **浅克隆够用**：autogen/configure 不读 git 历史（不像 containerd/runc 那样
  用 `git describe` 注入版本串），`--depth 1` 不影响 `ruby -v` 输出。

## 产物与验证

产物在 `ruby/ruby_v/linux/4_0_7/project/build/ruby`（外加 `./libruby.so` 若被
configure 选中）。脚本按上游顺序验证：`ruby -v` → 打印 `RbConfig` 里的
`ruby_version`/`arch`/`OPENSSL`/`ENABLE_YJIT` → `make hello` → `require "openssl"`
（确认 openssl 扩展真的编出来了）。

## 没做的事

没跑 `make check`（上游那是 30–60 分钟的完整 spec 套件的量，本仓库的分支只做
"从源码编译出可执行产物"）；没 `make install`（装到 /usr/local 会污染 runner 的
系统 ruby，且对其他步骤没意义）。
