#! /bin/bash
cd "$(dirname "$0")"
sudo apt update
sudo apt install mold -y
mold --version
sudo apt install build-essential clang cmake git libgl1 libx11-dev libxkbfile-dev libxrandr-dev libxi-dev libgl1-mesa-dev xorg-dev -y
sudo apt install libalsa-dev -y
git clone https://github.com/zed-industries/zed.git
cd zed
script/linux
cargo run --release