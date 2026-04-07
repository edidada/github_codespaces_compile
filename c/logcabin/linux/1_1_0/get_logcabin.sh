#!/bin/bash

set -e

echo "=========================================="
echo "LogCabin Build Script for Ubuntu"
echo "=========================================="

echo ""
echo "[1/4] Installing dependencies..."
sudo apt-get update
sudo apt-get install -y \
    git \
    scons \
    g++ \
    protobuf-compiler \
    libprotobuf-dev \
    libcrypto++-dev \
    doxygen \
    libssl-dev \
    zlib1g-dev

echo ""
echo "[2/4] Cloning LogCabin repository v1.1.0..."
if [ ! -d "logcabin" ]; then
    git clone -b v1.1.0 git://github.com/logcabin/logcabin.git
fi
cd logcabin

echo ""
echo "[3/4] Initializing git submodules..."
git submodule update --init

echo ""
echo "[4/4] Building LogCabin with scons..."
scons

echo ""
echo "[5/5] Build completed successfully!"
echo ""
echo "You can now run:"
echo "  - build/test/test          (run unit tests)"
echo "  - build/Examples/SmokeTest --mock && echo 'Smoke test completed successfully'"
echo "  - build/LogCabin --help    (start a server)"
echo ""
echo "=========================================="
