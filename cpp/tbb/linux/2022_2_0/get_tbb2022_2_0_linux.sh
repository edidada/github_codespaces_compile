#!/bin/bash

# Script to download, extract, and install oneTBB v2022.2.0 on Ubuntu 24.04
# Configured for Debug build as specified

# Variables
TBB_VERSION="2022.2.0"
TBB_SRC_URL="https://github.com/oneapi-src/oneTBB/archive/refs/tags/v${TBB_VERSION}.tar.gz"
TBB_DIR="oneTBB-${TBB_VERSION}"
INSTALL_PREFIX="/usr/local"  # Change if desired, e.g., "$HOME/.local"

echo "Starting oneTBB ${TBB_VERSION} installation (Debug build) on Ubuntu 24.04..."

# Step 1: Update package list and install prerequisites
echo "Updating system and installing prerequisites..."
sudo apt update
sudo apt install -y wget build-essential cmake pkg-config libicu-dev bazel-bootstrap

# Step 2: Download the tarball
echo "Downloading oneTBB tarball..."
wget -O oneapi-tbb-${TBB_VERSION}-lin.tgz "${TBB_SRC_URL}"

# Step 3: Extract the tarball
echo "Extracting tarball..."
tar -xzf oneapi-tbb-${TBB_VERSION}-lin.tgz
cd "${TBB_DIR}"

# Step 4: Create build directory and configure with CMake
echo "Configuring build with CMake (Debug mode)..."
mkdir build
cd build
cmake .. \
    -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
    -DCMAKE_BUILD_TYPE=Debug \
    -DTBB_TEST=OFF \
    -DTBB_STRICT=OFF \
    -DCMAKE_CXX_COMPILER=g++

# Step 5: Compile
echo "Compiling oneTBB (Debug build)..."
make -j$(nproc)

# Step 6: Install
echo "Installing oneTBB..."
sudo make install

# Step 7: Clean up
cd ../..
rm -rf "${TBB_DIR}" oneapi-tbb-${TBB_VERSION}-lin.tgz

# Step 8: Update library cache
echo "Updating library cache..."
sudo ldconfig

# Step 9: Set environment variables
echo "Adding environment variables to ~/.bashrc..."
cat >> ~/.bashrc << EOF

# oneTBB ${TBB_VERSION} environment
export TBBROOT="${INSTALL_PREFIX}"
export CPATH="\${TBBROOT}/include:\${CPATH}"
export LIBRARY_PATH="\${TBBROOT}/lib:\${LIBRARY_PATH}"
export LD_LIBRARY_PATH="\${TBBROOT}/lib:\${LD_LIBRARY_PATH}"
export PKG_CONFIG_PATH="\${TBBROOT}/lib/pkgconfig:\${PKG_CONFIG_PATH}"
EOF

source ~/.bashrc

echo "Installation complete! oneTBB (Debug build) is installed to ${INSTALL_PREFIX}."
echo "Run 'source ~/.bashrc' in new terminals or restart your shell."
echo "Verify with: pkg-config --modversion tbb"
