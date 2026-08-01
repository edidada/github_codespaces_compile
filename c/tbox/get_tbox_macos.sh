#! /bin/bash
cd "$(dirname "$0")"
echo "pwd"
pwd
which brew
git clone https://github.com/tboox/tbox.git
cd tbox
git checkout v1.7.7
find /usr/local/include/ -name "tbox.h"
curl -fsSL https://xmake.io/shget.text | bash
xmake --version
xmake -v
xmake install --installdir=/usr/local/Cellar/tbox/1.7.7