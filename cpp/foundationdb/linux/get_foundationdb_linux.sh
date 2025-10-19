#! /bin/bash
cd "$(dirname "$0")"
TOTAL_RAM=$(free -h | awk '/^Mem:/ {print $2}')
echo "local sys (RAM) is: $TOTAL_RAM"
sudo apt update
export BUILD_DIR=$HOME
cd ${BUILD_DIR}
wget https://github.com/apple/foundationdb/releases/download/7.1.67/foundationdb-server_7.1.67-1_amd64.deb  https://github.com/apple/foundationdb/releases/download/7.1.67/foundationdb-clients_7.1.67-1_amd64.deb
dpkg -i foundationdb-server_7.1.67-1_amd64.deb foundationdb-clients_7.1.67-1_amd64.deb
cd ${BUILD_DIR}
wget https://github.com/libfuse/libfuse/releases/download/fuse-3.16.2/fuse-3.16.2.tar.gz
tar -zxvf fuse-3.16.2.tar.gz
cd fuse-3.16.2; mkdir build; cd build
meson setup ..
ninja
ninja install