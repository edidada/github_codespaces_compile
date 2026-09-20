#! /bin/bash
cd "$(dirname "$0")"
TOTAL_RAM=$(free -h | awk '/^Mem:/ {print $2}')
echo "local sys (RAM) is: $TOTAL_RAM"
sudo apt update
echo "ubuntu version"
lsb_release -a
hostnamectl
# 安装 StarRocks 编译所需的系统依赖
sudo apt install -y build-essential cmake automake autoconf libtool bison byacc flex binutils-dev libiberty-dev libssl-dev libcurl4-openssl-dev libldap2-dev libltdl-dev \
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
# 隐藏 runner 预装的 swift，避免 thrift-0.23.0 configure 检测到 swift 后
# 在 make install 阶段执行无效的 'swift install' 子命令导致构建失败
if [ -f /usr/local/bin/swift ]; then
  sudo mv /usr/local/bin/swift /usr/local/bin/swift.bak
  echo "Temporarily masked /usr/local/bin/swift to skip thrift swift bindings"
fi
# 预下载 thrift-0.23.0.tar.gz 到 thirdparty/src，避免 Apache archive 服务器连接慢导致卡住
THIRDPARTY_SRC=${BUILD_DIR}/starrocks/thirdparty/src
mkdir -p ${THIRDPARTY_SRC}
THRIFT_TARBALL=thrift-0.23.0.tar.gz
if [ ! -f ${THIRDPARTY_SRC}/${THRIFT_TARBALL} ]; then
  echo "Pre-downloading ${THRIFT_TARBALL} ..."
  # 优先使用 Apache archive，失败则回退到 dlcdn.apache.org 镜像
  wget -t 3 -T 30 -q --show-progress -O ${THIRDPARTY_SRC}/${THRIFT_TARBALL} \
    https://archive.apache.org/dist/thrift/0.23.0/${THRIFT_TARBALL} \
    || wget -t 3 -T 30 -q --show-progress -O ${THIRDPARTY_SRC}/${THRIFT_TARBALL} \
    https://dlcdn.apache.org/thrift/0.23.0/${THRIFT_TARBALL} \
    || wget -t 3 -T 60 -O ${THIRDPARTY_SRC}/${THRIFT_TARBALL} \
    https://archive.apache.org/dist/thrift/0.23.0/${THRIFT_TARBALL}
  if [ ! -s ${THIRDPARTY_SRC}/${THRIFT_TARBALL} ]; then
    echo "Failed to download ${THRIFT_TARBALL}"
    exit 1
  fi
  echo "Pre-downloaded ${THRIFT_TARBALL} successfully"
fi
# 使用官方 build.sh 进行编译（默认构建 BE 和 FE）
bash build.sh
BUILD_EXIT_CODE=$?
if [ ${BUILD_EXIT_CODE} -ne 0 ]; then
  echo "StarRocks 3.5.20 build FAILED with exit code ${BUILD_EXIT_CODE}"
  exit ${BUILD_EXIT_CODE}
fi
# 列出构建产物
echo "==== build output ===="
ls -la output/ 2>/dev/null || echo "output/ directory not found"
ls -la output/be/lib/ 2>/dev/null || true
ls -la output/fe/ 2>/dev/null || true
echo "StarRocks 3.5.20 build finished."
