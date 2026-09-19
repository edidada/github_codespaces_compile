#!/usr/bin/env bash
set -euo pipefail
chmod +x ./cpp/tinyrpc_v/linux/latest/get_tinyrpc.sh
./cpp/tinyrpc_v/linux/latest/get_tinyrpc.sh
cd "$(dirname "$0")"
git clone https://github.com/Gooddbird/charon.git
find charon -type f \( -name '*.cc' -o -name '*.h' \) -exec sed -i \
  -e 's/AppDebugLog/DebugLog/g' \
  -e 's/AppInfoLog/InfoLog/g' \
  -e 's/AppWarnLog/WarnLog/g' \
  -e 's/AppErrorLog/ErrorLog/g' {} +
cd charon/charon/pb
protoc --cpp_out=./ charon.proto
cd ../
mkdir -p ../obj ../bin ../test_client/test_tool
make -j5
