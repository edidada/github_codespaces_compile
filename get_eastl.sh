#!/bin/bash
cd "$(dirname "$0")"
sudo apt-get update
git clone https://github.com/electronicarts/EASTL.git
cd EASTL
git checkout 3.21.12
mkdir your_build_folder && cd your_build_folder
cmake eastl_source_folder -DEASTL_BUILD_TESTS:BOOL=OFF
cmake --build . --config your_config
cd test && ctest -C your_config