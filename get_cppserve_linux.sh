#!/bin/bash
cd "$(dirname "$0")"
sudo apt update
git clone https://github.com/charmber/Cppserve.git
cd Cppserve
git checkout 395b0cd5e42813dc968a7942b430a372d8365253
# 默认变量值
BUILD_DIR="build"
PARALLEL_VALUE="4"
CONFIG_VALUE="Debug"
cmake -S . -B "$BUILD_DIR"
cmake --build "$BUILD_DIR" --parallel "$PARALLEL_VALUE" --config "$CONFIG_VALUE"