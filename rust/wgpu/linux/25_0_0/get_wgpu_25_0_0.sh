#! /bin/bash
sudo apt-get update
sudo apt install -y gettext autopoint gperf ninja-build
cd "$(dirname "$0")"
git clone https://github.com/gfx-rs/wgpu.git
cd wgpu
git checkout v26.0.0
cargo build