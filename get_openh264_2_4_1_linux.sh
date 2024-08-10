#! /bin/bash
cd "$(dirname "$0")"
sudo apt update
which meson
which ninja
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install nasm
which nasm
sudo apt install -y ninja-build meson
git clone https://github.com/cisco/openh264.git
cd openh264
git checkout v2.4.1
meson builddir
ninja -C builddir
meson test -C builddir -v
