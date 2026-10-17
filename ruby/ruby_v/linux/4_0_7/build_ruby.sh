#!/usr/bin/env bash
set -euo pipefail

# ruby v4.0.7：ruby/ruby 当前最新稳定标签（4.0 系列第一个 patch 之后的维护版，
# 4.1.0 还只有 preview1）。这里是编译 CRuby 解释器本体（maglev/YJIT 那套 3.x/4.x VM）。
RUBY_TAG="v4.0.7"
RUBY_REPO="https://github.com/ruby/ruby.git"

cd "$(dirname "$0")"

# 1. 依赖按上游 .github/actions/setup/ubuntu/action.yml 那一串：
#    build-essential / libssl-dev / libyaml-dev / readline / zlib / ncurses / libffi /
#    autoconf / ruby（baseruby，跑 tool/lrama 等生成器）/ pkg-config。
#    注意上游写的是 libreadline6-dev、libncurses5-dev（jammy 的老包名），
#    noble 上对应 libreadline-dev、libncurses-dev，这里先装新名字，
#    老名字装了也不报错（|| true）。
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
    build-essential \
    autoconf \
    automake \
    pkg-config \
    git \
    curl \
    wget \
    tar \
    ca-certificates \
    ruby \
    libssl-dev \
    libyaml-dev \
    libreadline-dev \
    zlib1g-dev \
    libncurses-dev \
    libffi-dev
sudo apt-get install -y --no-install-recommends libreadline6-dev libncurses5-dev || true

# 2. 取源码。上游 CI 会设 core.autocrlf=false，ruby 仓库里有 .gemspec / 测试数据，
#    混进 CRLF 会让 baseruby 阶段的一些校验出问题，照抄。
rm -rf project
git config --global core.autocrlf false || true
git config --global core.eol lf || true
git clone --branch "${RUBY_TAG}" --depth 1 "${RUBY_REPO}" project
cd project

# 3. git checkout 的 ruby 仓库里 configure 是未跟踪的生成物，必须先跑 autogen.sh
#    （内部就是 autoreconf --install --symlink）。这就是上游 apt 里装 autoconf 的原因，
#    也是为什么不能只下个 tar 包。
./autogen.sh --install

# 4. YJIT 需要 rustc（x86_64-linux 上默认开启）。runner 里有 rust 就正常编，
#    没有就显式关掉，别让 configure 半路报 "yjit requires Rust"。
CONFIGURE_EXTRA=()
if ! command -v rustc >/dev/null 2>&1; then
    echo "未检测到 rustc，禁用 YJIT"
    CONFIGURE_EXTRA+=(--disable-yjit)
fi

# 5. 上游用 out-of-source 构建：build 目录里跑 ../configure -C --disable-install-doc
#    （-C 是 autoconf 的 --config-cache；--disable-install-doc 跳过 rdoc/ri 安装，
#      那是最耗时的阶段）。
mkdir -p build
cd build
../configure -C --disable-install-doc "${CONFIGURE_EXTRA[@]}"
make -j"$(nproc)"

# 6. 产物校验
echo "==== ruby ===="
ls -lh ./ruby
file ./ruby
./ruby -v
./ruby -e 'require "rbconfig"; p({version: RbConfig::CONFIG["ruby_version"],
                                  arch: RbConfig::CONFIG["arch"],
                                  openssl: RbConfig::CONFIG["OPENSSL"],
                                  yjit: RbConfig::CONFIG.fetch("ENABLE_YJIT", "n/a")})'

# 上游 CI 在 make 之后跑 `make hello`，这里也跑一次，确认扩展/标准库挂载正常
make hello
./ruby -ropenssl -e 'p OpenSSL::OPENSSL_VERSION' 2>/dev/null || \
    ./ruby -I../lib -I.ext/common -ropenssl -e 'p OpenSSL::OPENSSL_VERSION'

echo "完成：ruby ${RUBY_TAG} 已从源码构建"
