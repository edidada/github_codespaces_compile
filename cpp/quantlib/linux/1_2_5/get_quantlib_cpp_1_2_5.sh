#!/bin/bash
sudo apt update
sudo apt install -y build-essential libboost-all-dev
# 2. 下载 QuantLib 源码
wget https://github.com/lballabio/QuantLib/releases/download/QuantLib-v1.31/QuantLib-1.31.tar.gz
# 3. 解压并编译
tar -xzf QuantLib-1.31.tar.gz
cd QuantLib-1.31
# 4. 配置编译选项
./configure --prefix=/usr/local
# 5. 编译并安装
make -j$(nproc)
sudo make install
# 6. 更新动态链接库缓存
sudo ldconfig
# 7. 验证安装
pkg-config --modversion QuantLib