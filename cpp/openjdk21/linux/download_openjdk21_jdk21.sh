#!/bin/bash
# 基础编译工具
sudo apt update && sudo apt install -y git build-essential autoconf cmake

# X11图形库依赖
sudo apt install -y libx11-dev libxext-dev libxrender-dev \
     libxtst-dev libxt-dev libxrandr-dev

# 其他运行时依赖
sudo apt install -y libcups2-dev libfontconfig1-dev \
     libasound2-dev libfreetype6-dev libzip-dev
wget https://codeload.github.com/openjdk/jdk21/zip/refs/heads/master -O jdk21-master.zip
unzip jdk21-master.zip
wget https://download.java.net/openjdk/jdk20/ri/openjdk-20+36_linux-x64_bin.tar.gz
tar -zxvf openjdk-20+36_linux-x64_bin.tar.gz -C /opt/
cd jdk21-master
bash configure \
  --with-num-cores=12 \                # 根据CPU核心数调整
  --with-memory-size=20480 \           # 内存分配（单位MB）
  --with-boot-jdk=/opt/jdk-20 \        # 指向JDK20路径
  --with-target-bits=64 \              # 64位系统
  --with-jvm-variants=server \         # 服务器版JVM
  --with-debug-level=slowdebug \       # 调试模式
  --disable-warnings-as-errors         # 忽略警告错误
make CONF=linux-x86_64-server-slowdebug
find build/ -name "java" -type f
# 典型路径：build/linux-x86_64-server-slowdebug/jdk/bin/java
./build/linux-x86_64-server-slowdebug/jdk/bin/java -version
