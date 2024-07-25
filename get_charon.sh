#!/bin/bash
chmod +x ./get_tinyrpc.sh
./get_tinyrpc.sh
cd "$(dirname "$0")"
git clone https://github.com/Gooddbird/charon.git
cd charon
cd charon
make -j5