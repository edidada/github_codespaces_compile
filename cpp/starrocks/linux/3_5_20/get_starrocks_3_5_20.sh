#! /bin/bash
cd "$(dirname "$0")"
TOTAL_RAM=$(free -h | awk '/^Mem:/ {print $2}')
echo "local sys (RAM) is: $TOTAL_RAM"
sudo apt update
echo "ubuntu version"
lsb_release -a
hostnamectl
# 安装 StarRocks 编译所需的系统依赖
sudo apt install -y build-essential cmake automake autoconf libtool bison binutils-dev libiberty-dev libssl-dev libcurl4-openssl-dev libldap2-dev libltdl-dev libunwind-dev \
    python3 python3-pip openjdk-17-jdk maven ninja-build ccache pkg-config zip unzip tar git wget
# 设置 Java 环境
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH
java -version
mvn -version
cmake --version
ninja --version
# 克隆 StarRocks 源码并切换到 3.5.20 版本
BUILD_DIR=$HOME
cd ${BUILD_DIR}
if [ ! -d "starrocks" ]; then
  git clone https://github.com/StarRocks/starrocks.git
fi
cd starrocks
git checkout 3.5.20
git submodule update --init --recursive
# 使用官方 build.sh 进行编译（默认构建 BE 和 FE）
bash build.sh
# 列出构建产物
ls -la output/
ls -la output/be/lib/ 2>/dev/null || true
ls -la output/fe/ 2>/dev/null || true
echo "StarRocks 3.5.20 build finished."
