#!/bin/bash
sudo apt update
sudo apt install -y python3-pytest
cd "$(dirname "$0")"
if [ ! -f pybind11.zip ]; then
  wget -O  pybind11.zip https://github.com/pybind/pybind11/archive/refs/tags/v2.13.6.zip
fi

unzip pybind11.zip
mv pybind11-2.13.6 source
mkdir build install
cmake source -B build -G Ninja \
  -DCMAKE_INSTALL_PREFIX="$(realpath install)" \
  -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF
cmake --build build --target check
cmake --build build --target install
