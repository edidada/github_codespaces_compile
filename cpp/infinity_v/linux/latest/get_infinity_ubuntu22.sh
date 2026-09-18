#! /bin/bash
sudo apt update
cd "$(dirname "$0")"
sudo apt update && sudo apt install git wget unzip software-properties-common
wget https://github.com/Kitware/CMake/releases/download/v3.29.0/cmake-3.29.0-linux-x86_64.tar.gz
tar zxvf cmake-3.29.0-linux-x86_64.tar.gz
sudo cp -rf cmake-3.29.0-linux-x86_64/bin/* /usr/local/bin && sudo cp -rf cmake-3.29.0-linux-x86_64/share/* /usr/local/share && rm -rf cmake-3.29.0-linux-x86_64
wget https://github.com/ninja-build/ninja/releases/download/v1.12.1/ninja-linux.zip
unzip ninja-linux.zip && sudo cp ninja /usr/local/bin && rm ninja
wget https://apt.llvm.org/llvm.sh && chmod +x llvm.sh && sudo ./llvm.sh 18 && rm llvm.sh
sudo add-apt-repository -P ppa:ubuntu-toolchain-r/test
sudo add-apt-repository -P ppa:mhier/libboost-latest
sudo apt update && sudo apt install libc++-18-dev clang-tools-18 flex libboost1.81-dev liblz4-dev zlib1g-dev libevent-dev libjemalloc-dev python3-dev
sudo ln -s /usr/lib/llvm-18/bin/clang-scan-deps /usr/bin/clang-scan-deps
sudo ln -s /usr/bin/clang-format-18 /usr/bin/clang-format
sudo ln -s /usr/bin/clang-tidy-18 /usr/bin/clang-tidy
sudo ln -s /usr/bin/llvm-symbolizer-18 /usr/bin/llvm-symbolizer
sudo ln -s /usr/lib/llvm-18/include/x86_64-pc-linux-gnu/c++/v1/__config_site /usr/lib/llvm-18/include/c++/v1/__config_site
git clone https://github.com/infiniflow/infinity.git
sudo apt install libsimde-dev -y
git config --global --add safe.directory infinity
cd infinity && mkdir cmake-build-debug && cd cmake-build-debug
export CC=/usr/bin/clang-18
export CXX=/usr/bin/clang++-18
cmake -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_VERBOSE_MAKEFILE=ON -DCMAKE_VERBOSE_MAKEFILE=ON ..
cmake --build .
