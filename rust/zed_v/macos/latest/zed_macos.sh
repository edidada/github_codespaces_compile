#! /bin/bash
cd "$(dirname "$0")"
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
git clone https://github.com/zed-industries/zed.git
cd zed
cargo run