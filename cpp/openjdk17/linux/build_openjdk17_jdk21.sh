#!/bin/bash
cd "$(dirname "$0")"
#!/bin/bash
# OpenJDK 17 源码编译脚本 - GitHub Actions 优化版
set -e  # 遇到错误立即退出

echo "🚀 开始编译 OpenJDK 17..."

# ================================
# 1. 基础编译工具 + 依赖
# ================================
echo "📦 安装编译依赖..."
sudo apt update -qq
sudo apt install -y \
    git build-essential autoconf automake \
    cmake ninja-build \
    libx11-dev libxext-dev libxrender-dev \
    libxtst-dev libxt-dev libxrandr-dev \
    libcups2-dev libfontconfig1-dev \
    libasound2-dev libfreetype6-dev \
    libzip-dev libpng-dev libjpeg8-dev \
    libgif-dev libv4l-dev \
    libusb-1.0-0-dev libxml2-dev \
    libxslt1-dev libgl1-mesa-dev \
    libglu1-mesa-dev libgtk-3-dev \
    unzip zip wget \
    python3 python3-pip \
    freetype2-demos fontconfig

echo "✅ 依赖安装完成"
echo "当前目录: $(pwd)"

# ================================
# 2. 下载引导 JDK 17（编译 OpenJDK 17 需要 JDK 17+）
# ================================
echo "📥 下载引导 JDK 17..."
mkdir -p ~/jdk17-bootstrap
cd ~/jdk17-bootstrap

# 使用最新稳定版 OpenJDK 17
wget --no-verbose \
    https://download.java.net/java/GA/jdk17.0.2/dfd4a8d0985749f896bed50d7138ee7f/8/GPL/openjdk-17.0.2_linux-x64_bin.tar.gz \
    -O openjdk-17.0.2_linux-x64_bin.tar.gz

tar -xzf openjdk-17.0.2_linux-x64_bin.tar.gz
mv jdk-17.0.2 ~/jdk17-bootstrap/jdk-17

export BOOT_JDK="$HOME/jdk17-bootstrap/jdk-17"
export JAVA_HOME="$BOOT_JDK"
export PATH="$JAVA_HOME/bin:$PATH"

echo "✅ 引导 JDK 17 安装完成"
$JAVA_HOME/bin/java -version
$JAVA_HOME/bin/javac -version

# ================================
# 3. 下载 OpenJDK 17 源码
# ================================
echo "📥 下载 OpenJDK 17 源码..."
cd ~/

# 删除旧文件（避免冲突）
rm -rf openjdk-17 jdk17-master.zip

# 从 GitHub 下载最新 OpenJDK 17 主分支
wget --no-verbose \
    https://codeload.github.com/openjdk/jdk17u/zip/refs/heads/master \
    -O jdk17-master.zip

unzip jdk17-master.zip
mv jdk17u-master openjdk-17

echo "✅ OpenJDK 17 源码下载完成"
cd openjdk-17
pwd

# ================================
# 4. 配置编译环境
# ================================
echo "⚙️ 配置编译环境..."

# 检测系统架构
BUILD_SYSTEM=$(./configure --help | grep "build" | head -1 || echo "linux-x86_64")

# 清理旧配置
make clean CONF=linux-x86_64-server-release 2>/dev/null || true

# 配置参数（OpenJDK 17 优化）
bash configure \
    --with-boot-jdk="$BOOT_JDK" \
    --with-target-bits=64 \
    --with-num-cores=8 \
    --with-memory-size=16384 \
    --with-jvm-variants=server \
    --with-debug-level=release \
    --disable-warnings-as-errors \
    --with-toolchain-type=gcc \
    --enable-jfr \
    --with-cacerts-prepended=/usr/share/ca-certificates \
    --with-gtest=/usr \
    --with-extra-cflags="-fno-semantic-interposition" \
    --with-extra-cxxflags="-fno-semantic-interposition" \
    2>&1 | tee configure.log

if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "❌ 配置失败，查看 configure.log"
    tail -20 configure.log
    exit 1
fi

echo "✅ 配置成功！"

# ================================
# 5. 编译 OpenJDK 17
# ================================
echo "🔨 开始编译 OpenJDK 17（15-30分钟）..."

# 并行编译，使用所有可用核心
make \
    CONF=linux-x86_64-server-release \
    JOBS=8 \
    LOG=info \
    2>&1 | tee build.log

# ================================
# 6. 验证编译结果
# ================================
echo "🧪 验证编译结果..."

# 查找 Java 可执行文件
JDK_BIN=$(find build/ -name "java" -type f -path "*/jdk/bin/java" | head -1)

if [ -n "$JDK_BIN" ]; then
    echo "✅ 找到编译的 JDK: $JDK_BIN"
    dirname "$JDK_BIN" | xargs dirname  # 显示 JDK 根目录

    # 测试运行
    "$JDK_BIN" -version
    echo "✅ OpenJDK 17 编译成功！"

    # 显示构建信息
    "$JDK_BIN" -XshowSettings:vm -version 2>&1 | head -20

else
    echo "❌ 未找到编译的 JDK"
    exit 1
fi

# ================================
# 7. 打包发布
# ================================
echo "📦 打包 OpenJDK 17..."

# 确定构建目录
BUILD_DIR=$(find build/ -name "jdk" -type d -path "*/linux-x86_64-server-release/jdk" | head -1)
if [ -z "$BUILD_DIR" ]; then
    BUILD_DIR=$(find build/ -name "images" -type d | head -1)/jdk
fi

if [ -d "$BUILD_DIR" ]; then
    # 创建发布目录
    mkdir -p ~/openjdk17-release
    cp -r "$BUILD_DIR" ~/openjdk17-release/openjdk-17-linux-x64

    # 打包
    cd ~/openjdk17-release
    tar -czf openjdk-17-linux-x64.tar.gz openjdk-17-linux-x64

    # 显示大小
    ls -lh openjdk-17-linux-x64.tar.gz
    du -sh openjdk-17-linux-x64

    echo "✅ 打包完成！"
    echo "📦 压缩包: ~/openjdk17-release/openjdk-17-linux-x64.tar.gz"

    # 设置环境变量
    export JDK17_HOME="$HOME/openjdk17-release/openjdk-17-linux-x64"
    export PATH="$JDK17_HOME/bin:$PATH"
    echo "JDK17_HOME=$JDK17_HOME" >> $GITHUB_ENV
    echo "$JDK17_HOME/bin" >> $GITHUB_PATH

else
    echo "❌ 未找到构建目录"
    exit 1
fi

# ================================
# 8. 最终验证
# ================================
echo "🎉 最终验证..."
"$JDK17_HOME/bin/java" -version
"$JDK17_HOME/bin/javac" -version

echo "=================================="
echo "✅ OpenJDK 17 编译完成！"
echo "📁 JDK 位置: $JDK17_HOME"
echo "📦 压缩包: ~/openjdk17-release/openjdk-17-linux-x64.tar.gz"
echo "=================================="
