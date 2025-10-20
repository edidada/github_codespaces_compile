#!/bin/bash
# JDK 8 源码编译脚本 - Ubuntu 22.04
# 适用于 GitHub Actions / Codespaces / VPS

set -e  # 遇到错误立即退出

echo "🚀 开始编译 JDK 8（基于 JDK 7u80 引导）..."

# ================================
# 1. 更新系统并安装依赖
# ================================
echo "📦 安装编译 JDK 8 所需依赖..."
sudo apt-get update -qq
sudo apt-get install -y \
    autoconf \
    build-essential \
    ccache \
    cups \
    libasound2-dev \
    libcups2-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libx11-dev \
    libxext-dev \
    libxrender-dev \
    libxtst-dev \
    libxt-dev \
    libxinerama-dev \
    libxi-dev \
    libxrandr-dev \
    libxss-dev \
    libgtk-3-dev \
    libjpeg8-dev \
    libpng-dev \
    libgif-dev \
    libv4l-dev \
    libusb-1.0-0-dev \
    libxml2-dev \
    libxslt1-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libfreetype6-dev \
    libwebkit2gtk-4.0-dev \
    unzip \
    zip \
    wget \
    zip \
    unzip \
    alsa-lib-dev \
    ant \
    libwebkitgtk-3.0-dev

echo "✅ 依赖安装完成"

# ================================
# 2. 验证 JDK 7 环境
# ================================
echo "🔍 验证 JDK 7u80 环境..."
java -version
javac -version
echo "JAVA_HOME=$JAVA_HOME"
echo "PATH包含: $(which java)"
echo "✅ JDK 7u80 环境正常"

# ================================
# 3. 下载 JDK 8 源码
# ================================
echo "📥 下载 JDK 8u202 源码（最新稳定版）..."
cd /tmp

# 创建工作目录
mkdir -p ~/jdk8-build
cd ~/jdk8-build

# 下载 JDK 8 源码 (jdk8u202 为推荐稳定版本)
wget -q --show-progress \
    https://github.com/openjdk/jdk8u/archive/refs/tags/jdk8u202-b08.tar.gz \
    -O jdk8u202-b08.tar.gz

# 验证下载
ls -lh jdk8u202-b08.tar.gz
echo "✅ JDK 8 源码下载完成 (约 50MB)"

# ================================
# 4. 下载编译所需外部依赖
# ================================
echo "📦 下载外部依赖..."

# Bootstrap JDK (使用已有的 JDK 7)
export BOOT_JDK="$JAVA_HOME"

# 下载 FreeType (字体渲染)
wget -q --show-progress \
    https://download.savannah.gnu.org/releases/freetype/freetype-2.13.2.tar.gz \
    -O freetype-2.13.2.tar.gz

# 下载其他必要依赖
wget -q --show-progress \
    https://www.graphviz.org/download/source/graphviz-9.0.0.tar.gz \
    -O graphviz-9.0.0.tar.gz

echo "✅ 外部依赖下载完成"

# ================================
# 5. 解压和准备源码
# ================================
echo "📂 解压源码..."
tar -xzf jdk8u202-b08.tar.gz
mv jdk8u202-b08 jdk8u

tar -xzf freetype-2.13.2.tar.gz
mv freetype-2.13.2 freetype

echo "✅ 源码解压完成"

# ================================
# 6. 配置编译环境
# ================================
echo "⚙️ 配置编译环境..."

cd ~/jdk8-build/jdk8u

# 设置环境变量
export PATH="$JAVA_HOME/bin:$PATH"
export LD_LIBRARY_PATH="$JAVA_HOME/jre/lib/amd64:$LD_LIBRARY_PATH"

# 配置编译参数
bash configure \
    --with-boot-jdk="$JAVA_HOME" \
    --with-freetype=/home/runner/jdk8-build/freetype \
    --with-cups-include=/usr/include \
    --with-fontconfig-include=/usr/include/fontconfig \
    --with-fontconfig-lib=/usr/lib/x86_64-linux-gnu \
    --enable-debug \
    --with-debug-level=slowdebug \
    --with-target-bits=64 \
    --disable-precompiled-headers \
    --with-jvm-variants=server \
    --disable-hotspot-builtin-bc \
    --disable-zip-debug-info \
    2>&1 | tee configure.log

if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "❌ 配置失败，查看 configure.log"
    cat configure.log
    exit 1
fi

echo "✅ 配置成功"

# ================================
# 7. 编译 JDK 8
# ================================
echo "🔨 开始编译 JDK 8（需要 30-60 分钟）..."

# 使用 ccache 加速编译
export USE_CCACHE=1

# 并行编译（使用所有 CPU 核心）
make clean  # 清理旧构建
make all \
    JOBS=4 \
    HOTSPOT_BUILD_USER="github-actions" \
    LOG=trace \
    2>&1 | tee build.log

# 验证编译结果
if [ -f "build/linux-x86_64-normal-server-slowdebug/jdk/bin/java" ]; then
    echo "✅ JDK 8 编译成功！"
else
    echo "❌ 编译失败"
    exit 1
fi

# ================================
# 8. 测试编译结果
# ================================
echo "🧪 测试编译的 JDK 8..."

cd build/linux-x86_64-normal-server-slowdebug/jdk/bin
./java -version
./javac -version

echo "✅ JDK 8 测试通过！"

# ================================
# 9. 打包发布
# ================================
echo "📦 打包 JDK 8..."

cd ~/jdk8-build/jdk8u/build/linux-x86_64-normal-server-slowdebug

# 创建发布目录
mkdir -p ~/jdk8-release
cp -r jdk ~/jdk8-release/jdk8u202-linux-x64

# 打包
cd ~/jdk8-release
tar -czf jdk8u202-linux-x64.tar.gz jdk8u202-linux-x64

# 显示大小
ls -lh jdk8u202-linux-x64.tar.gz

echo "✅ JDK 8 打包完成！"

# ================================
# 10. 设置环境变量（供后续使用）
# ================================
echo "🔧 设置 JDK 8 环境变量..."
export JDK8_HOME="$HOME/jdk8-release/jdk8u202-linux-x64"
export PATH="$JDK8_HOME/bin:$PATH"

echo "JDK8_HOME=$JDK8_HOME" >> $GITHUB_ENV
echo "$JDK8_HOME/bin" >> $GITHUB_PATH

# ================================
# 11. 最终验证
# ================================
echo "🎉 最终验证..."
$JDK8_HOME/bin/java -version
$JDK8_HOME/bin/javac -version

echo "=================================="
echo "✅ JDK 8 编译完成！"
echo "📁 JDK 8 位置: $JDK8_HOME"
echo "📦 压缩包: ~/jdk8-release/jdk8u202-linux-x64.tar.gz"
echo "=================================="

# 可选：上传到 GitHub Release
# gh release create jdk8u202-v1.0 ~/jdk8-release/jdk8u202-linux-x64.tar.gz \
#     --title "JDK 8u202 Linux x64 (自编译)" \
#     --notes "基于 JDK 7u80 引导，自编译的 JDK 8u202"