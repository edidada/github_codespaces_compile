#!/bin/bash
# 基础编译工具
sudo apt update && sudo apt install -y git build-essential autoconf cmake
echo "build pwd"
pwd
# X11图形库依赖
sudo apt install -y libx11-dev libxext-dev libxrender-dev libxtst-dev libxt-dev libxrandr-dev libcups2-dev libfontconfig1-dev libasound2-dev libfreetype6-dev libzip-dev
wget https://codeload.github.com/openjdk/jdk21/zip/refs/heads/master -O jdk21-master.zip
unzip jdk21-master.zip
wget https://download.java.net/openjdk/jdk20/ri/openjdk-20+36_linux-x64_bin.tar.gz
tar -zxvf openjdk-20+36_linux-x64_bin.tar.gz -C /home/runner/work/github_codespaces_compile/github_codespaces_compile/
cd jdk21-master
export JAVA_HOME=/home/runner/work/github_codespaces_compile/github_codespaces_compile/jdk-20
bash configure --with-num-cores=12 --with-memory-size=20480 --with-boot-jdk=/home/runner/work/github_codespaces_compile/github_codespaces_compile/jdk-20 --with-target-bits=64 --with-jvm-variants=server --with-debug-level=slowdebug -disable-warnings-as-errors  --with-toolchain-type=gcc
make CONF=linux-x86_64-server-slowdebug
find build/ -name "java" -type f
./build/linux-x86_64-server-slowdebug/jdk/bin/java -version
