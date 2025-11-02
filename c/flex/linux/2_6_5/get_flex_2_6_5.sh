#! /bin/bash
sudo apt-get update
cd "$(dirname "$0")"
sudo apt install -y build-essential autoconf automake libtool m4 bison flex texinfo
git clone https://github.com/westes/flex.git
cd flex
git checkout v2.6.4
# 运行 autogen（如果需要）
./autogen.sh
# 配置（可选：指定安装路径）
./configure --prefix=/usr/local  # 或默认 /usr
# 编译
make -j$(nproc)  # 使用所有 CPU 核心加速
# 测试编译产物（见步骤 4）
make check  # 运行单元测试
# 安装（覆盖系统版）
sudo make install
/usr/local/bin/flex --version
