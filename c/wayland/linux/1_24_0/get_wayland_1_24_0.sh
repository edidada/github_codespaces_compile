#! /bin/bash
cd "$(dirname "$0")"
# 克隆 Wayland 代码库
git clone https://gitlab.freedesktop.org/wayland/wayland.git
cd wayland

# 查看所有分支和标签
git branch -a
git tag -l | sort -V | tail -10

# 切换到最新的稳定版本（以 1.24.0 为例）
git checkout 1.24.0

# 更新系统
sudo apt update

# 安装编译工具和依赖
sudo apt install -y \
    meson \
    ninja-build \
    pkg-config \
    build-essential \
    git \
    autoconf \
    automake \
    libtool

# 安装 Wayland 编译依赖
sudo apt install -y \
    libffi-dev \
    libexpat1-dev \
    libxml2-dev \
    doxygen \
    graphviz \
    xmlto

# 可选：文档生成依赖
sudo apt install -y \
    docbook-xsl \
    xsltproc

# 设置变量
PROJECT_DIR="$PWD"
BUILD_DIR="$PROJECT_DIR/build"
INSTALL_PREFIX="$PROJECT_DIR/install"

# 创建构建目录
mkdir -p "$BUILD_DIR"
mkdir -p "$INSTALL_PREFIX"

# 进入构建目录
cd "$BUILD_DIR"

# 配置 Meson 构建
meson setup \
    --prefix="$INSTALL_PREFIX" \
    --buildtype=release \
    --strip \
    -Ddocumentation=false \
    -Dtests=false \
    ..

# 编译
ninja

# 安装到指定目录
ninja install

echo "编译成功！"
echo "安装目录: $INSTALL_PREFIX"