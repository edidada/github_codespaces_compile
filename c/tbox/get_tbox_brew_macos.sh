#! /bin/bash
cd "$(dirname "$0")"
echo "pwd"
pwd
which brew
git clone https://github.com/tboox/tbox.git
cd tbox
git checkout v1.7.7
find /usr/local/include/ -name "tbox.h"
brew install xmake
xmake --version
xmake -v
sudo mkdir -p /usr/local/Cellar/tbox/1.7.7
sudo xmake install --installdir=~/.local/Cellar/tbox/1.7.7 --root