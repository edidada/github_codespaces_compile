#!/bin/bash
cd "$(dirname "$0")"
set -euo pipefail

echo "=== 准备环境 - Ubuntu 24.04 ==="
sudo apt update
sudo apt install -y \
  openjdk-17-jdk \
  openjdk-21-jdk \          # 部分模块可能需要更高版本 JDK
  maven \
  git \
  unzip \
  zip \
  ccache \
  python3 \
  python3-pip \
  nodejs \
  npm \
  yarn \
  libnss3 \
  libgtk-3-0 \
  libgbm-dev \
  xvfb \
  libasound2t64 \
  libc6-i386 \
  libstdc++6:i386 \
  libx11-6:i386

# 推荐设置 ccache 加速重复编译（可选但强烈推荐）
ccache --max-size=10G
export CCACHE_DIR="$HOME/.ccache"
export PATH="/usr/lib/ccache:$PATH"

echo "git clone idea_community"
git clone https://github.com/JetBrains/intellij-community.git
cd intellij-community
git clone https://github.com/JetBrains/android.git
echo "=== 开始编译 IntelliJ IDEA Community Edition ==="
./gradlew setupCIWorkflow
./gradlew :community:buildDist
