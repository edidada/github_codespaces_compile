#! /bin/bash
cd "$(dirname "$0")"
sudo apt update
sudo apt install -y ninja-build meson nasm
echo "meson version"
which meson
meson version
echo "ninja version"
which ninja
ninja version
echo "nasm version"
which nasm
nasm version
git clone https://github.com/cisco/openh264.git
cd openh264
git checkout v2.4.1
meson builddir
ninja -C builddir
meson test -C builddir -v
