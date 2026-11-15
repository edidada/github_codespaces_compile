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
#    prefix 指到 $HOME 下的独立目录：runner 的 /usr/local 里已经预装了系统 ruby，
#    装到那里会污染环境，而 make install 到一个可写 prefix 才是能直接跑的成品校验。
INSTALL_DIR="${HOME}/ruby-${RUBY_TAG#v}"
mkdir -p build
cd build
../configure -C --disable-install-doc --prefix="${INSTALL_DIR}" "${CONFIGURE_EXTRA[@]}"
make -j"$(nproc)"

# 6. 产物校验（构建树里的 ruby）
echo "==== ruby（构建树） ===="
ls -lh ./ruby
file ./ruby
./ruby -v
# 上游 CI 在 make 之后跑 `make hello`，这里也跑一次，确认标准库挂载正常
make hello

# 7. make install 后用安装好的 ruby 做校验。
#    不要直接用构建目录里的 ./ruby 去 require 东西：out-of-source 构建下它不会把
#    srcdir 的 lib、build 目录的 rbconfig.rb、.ext/<arch> 里的 .so 自动加进
#    $LOAD_PATH（日志里那串 "RubyGems were not loaded" 就是这个阶段），
#    显式 -I 得同时凑齐 .ext/common 和 .ext/<arch> 很容易写错，装完再测最省事。
make install
RUBY="${INSTALL_DIR}/bin/ruby"
"${RUBY}" -v
"${RUBY}" -e 'require "rbconfig"; p({version: RbConfig::CONFIG["ruby_version"],
                                     arch: RbConfig::CONFIG["arch"],
                                     openssl: RbConfig::CONFIG["OPENSSL"],
                                     yjit: RbConfig::CONFIG.fetch("ENABLE_YJIT", "n/a"),
                                     prefix: RbConfig::CONFIG["prefix"]})'
"${RUBY}" -ropenssl -e 'p OpenSSL::OPENSSL_LIBRARY_VERSION'
"${RUBY}" -ryaml -e 'p YAML.safe_load("ok: true")'
"${RUBY}" -e 'p Socket.gethostname' 2>/dev/null || true

echo "完成：ruby ${RUBY_TAG} 已从源码构建并安装到 ${INSTALL_DIR}"
