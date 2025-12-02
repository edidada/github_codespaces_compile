#! /bin/bash
sudo apt-get update
sudo apt install -y gettext autopoint gperf ninja-build
cd "$(dirname "$0")"
git clone https://github.com/rust-lang/rust.git
cd rust
git checkout 1.80.0
./configure
echo "which python"
which python
which python3
python3 /home/wdidada/rust/x.py build