#! /bin/bash
sudo apt update && sudo apt install git wget unzip software-properties-common
wget https://cmake.org/files/v3.28/cmake-3.28.1-linux-x86_64.tar.gz
tar zxvf cmake-3.28.1-linux-x86_64.tar.gz
sudo cp -rf cmake-3.28.1-linux-x86_64/bin/* /usr/local/bin && sudo cp -rf cmake-3.28.1-linux-x86_64/share/* /usr/local/share && rm -rf cmake-3.28.1-linux-x86_64
wget https://github.com/ninja-build/ninja/releases/download/v1.11.1/ninja-linux.zip
unzip ninja-linux.zip && sudo cp ninja /usr/local/bin && rm ninja
echo 'deb https://apt.llvm.org/jammy/ llvm-toolchain-jammy-17 main' | sudo tee /etc/apt/sources.list.d/llvm17.list
wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | sudo tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc
sudo add-apt-repository -P ppa:ubuntu-toolchain-r/test
sudo add-apt-repository -P ppa:mhier/libboost-latest
sudo apt update && sudo apt install g++-13 clang-17 clang-tools-17 flex libboost1.81-dev liblz4-dev libevent-dev liburing-dev libthrift-dev
ln -s /usr/lib/llvm-17/bin/clang-scan-deps /usr/bin/clang-scan-deps
git clone https://github.com/infiniflow/infinity.git
git config --global --add safe.directory infinity
cd infinity && mkdir build && cd build
export CC=/usr/bin/clang-17
export CXX=/usr/bin/clang++-17
cmake -G Ninja ..
ninja -j 12
./src/infinity
