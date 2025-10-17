#! /bin/bash
TOTAL_RAM=$(free -h | awk '/^Mem:/ {print $2}')
echo "local sys (RAM) is: $TOTAL_RAM"
sudo apt update
sudo apt install libboost-all-dev cmake libuv1-dev liblz4-dev liblzma-dev libdouble-conversion-dev libdwarf-dev libunwind-dev libaio-dev libgflags-dev libgoogle-glog-dev libgtest-dev libgmock-dev clang-format-14 clang-14 clang-tidy-14 lld-14 libgoogle-perftools-dev google-perftools libssl-dev gcc-12 g++-12 libboost-all-dev build-essential -y
ls /usr/include/boost
ls /usr/lib/x86_64-linux-gnu | grep boost
export BOOST_ROOT=/usr/local
export Boost_INCLUDE_DIR=/usr/include/boost
export Boost_LIBRARY_DIR=/usr/lib/x86_64-linux-gnu
git clone https://github.com/deepseek-ai/3fs
cd 3fs
git submodule update --init --recursive
./patches/apply.sh
echo "Building FoundationDB..."
cd third_party/foundationdb
mkdir -p build && cd build
cmake .. -DFDBCLIO=OFF -DUSE_LIBC++=ON
make -j4
export FDB_ROOT=$PWD
export PATH="$FDB_ROOT/bin:$PATH"
export LD_LIBRARY_PATH="$FDB_ROOT/lib:$LD_LIBRARY_PATH"
export CMAKE_PREFIX_PATH="$FDB_ROOT:$CMAKE_PREFIX_PATH"
cd ../../3fs
echo "Building pwd"
pwd
cmake -S . -B build -DCMAKE_CXX_COMPILER=clang++-14 -DCMAKE_C_COMPILER=clang-14 -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DFDB_ROOT=$FDB_ROOT
cmake --build build -j 5
