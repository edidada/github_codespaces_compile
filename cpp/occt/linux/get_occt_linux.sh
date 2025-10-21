#! /bin/bash
sudo apt update
cd "$(dirname "$0")"
# OCCT 自动编译安装脚本 for Linux

set -e # 遇到错误则退出脚本

# 配置参数 (可根据需要修改)
OCCT_VERSION="V7_7_0" # 建议使用最新稳定版或特定版本
INSTALL_PREFIX="/usr/local/occt" # 安装目录
BUILD_TYPE="Release" # 编译类型: Release, Debug, RelWithDebInfo
BUILD_DIR="./occt-build" # 构建临时目录
SOURCE_DIR="./occt-sources" # 源码目录 (如果自行下载)
NUM_JOBS=$(nproc) # 并行编译任务数，通常设为CPU核心数

# 第三方库依赖 (请根据您的发行版使用 apt, yum, dnf, zypper 等安装)
# 以下是基于 Ubuntu/Debian 的依赖安装命令
echo "[INFO] 安装系统依赖包..."
sudo apt-get update
sudo apt-get install -y \
    git build-essential cmake \
    libfreetype6-dev libx11-dev libxext-dev \
    libglu1-mesa-dev libgl1-mesa-dev \
    tcl8.6-dev tk8.6-dev libftgl-dev \
    freeglut3-dev libtbb-dev libfreeimage-dev \
    doxygen graphviz

# 获取源码 (方式1: 从GitHub克隆)
echo "[INFO] 克隆 OCCT 源码..."
if [ ! -d "$SOURCE_DIR" ]; then
    git clone https://github.com/Open-Cascade-SAS/OCCT.git $SOURCE_DIR
    cd $SOURCE_DIR
    git checkout V$OCCT_VERSION # 切换到特定版本标签 (如果需要)
    cd ..
else
    echo "[INFO] 源码目录已存在，跳过克隆"
fi

# 或者 (方式2: 如果已有源码包，解压到当前目录)
# SOURCE_DIR="./OCCT-$OCCT_VERSION"

# 创建构建目录
echo "[INFO] 创建构建目录..."
mkdir -p $BUILD_DIR
cd $BUILD_DIR

# CMake 配置
echo "[INFO] 配置 CMake..."
cmake $SOURCE_DIR \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DBUILD_LIBRARY_TYPE="Shared" \
    -DBUILD_CPP_STANDARD="C++11" \
    -DUSE_FREETYPE=ON \
    -DUSE_TBB=ON \
    -DUSE_FREEIMAGE=ON \
    -DUSE_TK=ON \
    -DBUILD_MODULE_Draw=ON \
    -DBUILD_DOC_Overview=OFF \
    -DBUILD_SAMPLES_QT=OFF

# 编译
echo "[INFO] 开始编译 (使用 $NUM_JOBS 个任务)..."
make -j$NUM_JOBS

# 运行测试 (可选)
echo "[INFO] 运行测试..."
make test

# 安装到指定目录
echo "[INFO] 安装到 $INSTALL_PREFIX..."
sudo make install

echo "[SUCCESS] OCCT 已成功安装到 $INSTALL_PREFIX"
echo "如需使用，请将以下路径添加到环境变量:"
echo "export PATH=$INSTALL_PREFIX/bin:\$PATH"
echo "export LD_LIBRARY_PATH=$INSTALL_PREFIX/lib:\$LD_LIBRARY_PATH"
echo "export CASROOT=$INSTALL_PREFIX"