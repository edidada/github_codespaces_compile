#! /bin/bash
sudo apt-get update
sudo apt install -y gettext autopoint gperf
cd "$(dirname "$0")"
git clone https://github.com/zigzap/zap.git
cd zap
git checkout v0.11.0
zig build run-hello
