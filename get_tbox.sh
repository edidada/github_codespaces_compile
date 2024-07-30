#!/bin/bash
cd "$(dirname "$0")"
sudo apt update
curl -fsSL https://xmake.io/shget.text | bash
git clone https://github.com/tboox/tbox.git
cd ./tbox
xmake