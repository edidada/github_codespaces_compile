#! /bin/bash
sudo apt update
git clone -b llvmorg-17.0.6 https://github.com/llvm/llvm-project.git
cd llvm-project
mkdir build_libcxx && cd build_libcxx
cmake -G Ninja -S runtimes -B build_libcxx -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;libunwind"
ninja -C build_libcxx cxx cxxabi unwind
ninja -C build_libcxx check-cxx check-cxxabi check-unwind
ninja -C build_libcxx install-cxx install-cxxabi install-unwind
cd ../