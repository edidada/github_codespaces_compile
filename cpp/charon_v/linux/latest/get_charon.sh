#!/usr/bin/env bash
set -euo pipefail
chmod +x ./cpp/tinyrpc_v/linux/latest/get_tinyrpc.sh
./cpp/tinyrpc_v/linux/latest/get_tinyrpc.sh
cd "$(dirname "$0")"
git clone https://github.com/Gooddbird/charon.git
find charon -type f \( -name '*.cc' -o -name '*.h' \) -exec sed -i \
  -e 's/AppInfoLog/InfoLog/g' \
  -e 's/AppErrorLog/ErrorLog/g' {} +
cd charon/charon/pb
protoc --cpp_out=./ charon.proto
cd ../
mkdir ../obj
make -j5
