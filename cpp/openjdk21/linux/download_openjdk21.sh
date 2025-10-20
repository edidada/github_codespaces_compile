#!/bin/bash

# 编译OpenJDK的Ubuntu脚本
# 适用于最新版OpenJDK (基于周志明《深入理解Java虚拟机》中的方法)
# 测试环境: Ubuntu 20.04/22.04 LTS

# 设置变量
JDK_VERSION="jdk-21"  # 可以修改为你想编译的版本，如jdk-17, jdk-20等
BUILD_DIR="$HOME/jvm_build"
OPENJDK_SOURCE_URL="https://github.com/openjdk/$JDK_VERSION"

echo $JDK_VERSION
echo $BUILD_DIR
echo $OPENJDK_SOURCE_URL

# 安装依赖
echo "安装编译依赖..."
sudo apt update
sudo apt install -y git build-essential libx11-dev libxext-dev libxrender-dev libxtst-dev libxt-dev \
    libcups2-dev libfontconfig1-dev libasound2-dev libfreetype6-dev \
    autoconf cmake zip unzip libssl-dev

# 安装引导JDK (比目标版本低1的JDK)
echo "安装引导JDK..."
sudo apt install -y openjdk-17-jdk  # 对于JDK 21，使用JDK 17作为引导

# 创建构建目录
mkdir -p $BUILD_DIR
cd $BUILD_DIR

# 获取源代码
echo "克隆OpenJDK源代码..."
git clone $OPENJDK_SOURCE_URL
cd $JDK_VERSION

# 配置构建环境
echo "配置构建环境..."
bash configure --enable-debug --with-jvm-variants=server \
    --with-boot-jdk=/usr/lib/jvm/java-17-openjdk-amd64 \
    --with-native-debug-symbols=internal \
    --with-freetype=bundled

# 检查配置是否成功
if [ $? -ne 0 ]; then
    echo "配置失败，请检查错误信息"
    exit 1
fi

# 开始编译
echo "开始编译JVM (这可能需要较长时间)..."
make images

# 检查编译结果
if [ $? -eq 0 ]; then
    echo ""
    echo "编译成功!"
    echo "编译结果位于: $BUILD_DIR/$JDK_VERSION/build/linux-x86_64-server-release/images/jdk"
    echo ""
    echo "你可以通过以下命令测试新编译的JDK:"
    echo "$BUILD_DIR/$JDK_VERSION/build/linux-x86_64-server-release/images/jdk/bin/java -version"
else
    echo "编译失败，请检查错误信息"
fi