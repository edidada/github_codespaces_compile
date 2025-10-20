#!/bin/bash
# JDK 8 源码编译脚本 - Ubuntu 22.04 完整版
# 切换到脚本目录
cd "$(dirname "${BASH_SOURCE[0]}")"

set -e

echo "🚀 开始编译 JDK 8（Ubuntu 22.04）..."

# ================================
# 1. 安装依赖（修正版）
# ================================
echo "📦 安装依赖..."
sudo apt-get update -qq
sudo apt-get install -y software-properties-common

sudo apt-get update -qq

sudo apt-get install -y \
    autoconf automake \
    build-essential ccache \
    cups libasound2-dev libcups2-dev \
    libfontconfig1-dev libfreetype6-dev \
    libx11-dev libxext-dev libxrender-dev \
    libxtst-dev libxt-dev \
    libxinerama-dev libxi-dev libxrandr-dev libxss-dev \
    libgtk-3-dev libjpeg8-dev libpng-dev libgif-dev \
    libv4l-dev libusb-1.0-0-dev libxml2-dev libxslt1-dev \
    libgl1-mesa-dev libglu1-mesa-dev \
    unzip zip wget ant \
    libwebkit2gtk-4.0-dev libjavascriptcoregtk-4.0-dev \
    libgdk-pixbuf2.0-dev libpulse-dev \
    fontconfig freetype2-demos \
    binutils-gold libelf-dev

echo "依赖安装完成"
echo "设置boost jdk7"

export JAVA_HOME="$HOME/jdk/jdk1.7.0_80"
export PATH="$JAVA_HOME/bin:$PATH"

java -version
javac -version

# ================================
# 3. 创建工作目录并下载源码
# ================================
mkdir -p ~/jdk8-build
cd ~/jdk8-build

echo "📥 下载 JDK 8u202 源码..."
wget -q --show-progress \
    https://github.com/openjdk/jdk8u/archive/refs/tags/jdk8u202-b08.tar.gz \
    -O jdk8u202-b08.tar.gz

ls -lh jdk8u202-b08.tar.gz

# ================================
# 4. 解压源码
# ================================
echo "📂 解压源码..."
tar -xzf jdk8u202-b08.tar.gz
mv jdk8u202-b08 jdk8u

cd jdk8u

# ================================
# 5. 配置编译
# ================================
echo "⚙️ 配置编译..."

bash configure \
    --with-boot-jdk="$BOOT_JDK" \
    --with-cups-include=/usr/include \
    --with-fontconfig-include=/usr/include/fontconfig \
    --with-fontconfig-lib=/usr/lib/x86_64-linux-gnu \
    --with-freetype-include=/usr/include/freetype2 \
    --with-freetype-lib=/usr/lib/x86_64-linux-gnu \
    --enable-debug \
    --with-debug-level=fastdebug \
    --with-target-bits=64 \
    --disable-precompiled-headers \
    --with-jvm-variants=server \
    --disable-hotspot-builtin-bc \
    --disable-zip-debug-info \
    2>&1 | tee configure.log

echo "配置成功"

# ================================
# 6. 编译 JDK 8
# ================================
echo "🔨 开始编译（30-60分钟）..."

# 清理并编译
make clean
make all \
    JOBS=4 \
    HOTSPOT_BUILD_USER="ubuntu22-builder" \
    LOG=trace \
    2>&1 | tee build.log

# ================================
# 7. 验证和打包
# ================================
BUILD_DIR="build/linux-x86_64-normal-server-fastdebug"
JDK_BIN="$BUILD_DIR/jdk/bin/java"

if [ -f "$JDK_BIN" ]; then
    echo "编译成功！"
    $JDK_BIN -version

    # 打包
    mkdir -p ~/jdk8-release
    cp -r $BUILD_DIR/jdk ~/jdk8-release/jdk8u202-linux-x64

    cd ~/jdk8-release
    tar -czf jdk8u202-linux-x64.tar.gz jdk8u202-linux-x64
    ls -lh jdk8u202-linux-x64.tar.gz

    echo "🎉 JDK 8 编译完成！"
    echo "📦 位置: ~/jdk8-release/jdk8u202-linux-x64.tar.gz"

    # 设置环境变量
    export JDK8_HOME="$HOME/jdk8-release/jdk8u202-linux-x64"
    export PATH="$JDK8_HOME/bin:$PATH"
    echo "JDK8_HOME=$JDK8_HOME" >> $GITHUB_ENV
    echo "$JDK8_HOME/bin" >> $GITHUB_PATH

else
    echo "❌ 编译失败"
    exit 1
fi