#! /bin/bash
cd "$(dirname "$0")"
set -e
sudo apt update
sudo apt install -y \
    build-essential \
    autoconf \
    automake \
    libtool \
    pkg-config \
    libssl-dev \
    libnl-3-dev \
    libnl-genl-3-dev \
    libnl-route-3-dev \
    libsnmp-dev \
    libjson-c-dev \
    libpopt-dev \
    libsystemd-dev \
    git
cd /tmp
if [ -d "keepalived" ]; then
    echo "检测到已存在的源码目录，删除中..."
    rm -rf keepalived
fi
git clone https://github.com/acassen/keepalived.git
cd keepalived
git checkout v2.2.2
./build_setup
if [ ! -f "configure" ]; then
    echo "生成 configure 脚本..."
    autoreconf -ivf
fi
echo "步骤 5: 配置编译参数..."
./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --enable-snmp \
    --enable-sha1 \
    --with-systemdsystemunitdir=/lib/systemd/system
echo "步骤 6: 编译安装..."
make -j$(nproc)
sudo make install
echo "步骤 7: 创建必要的目录和文件..."
sudo mkdir -p /etc/keepalived
sudo mkdir -p /var/run/keepalived