#!/bin/bash
chmod +x ./get_tinyrpc.sh
./get_tinyrpc.sh
cd "$(dirname "$0")"
git clone https://github.com/Gooddbird/charon.git
cd charon/charon/pb
protoc --cpp_out=./ charon.proto
cd ../
mkdir ../obj
make -j5