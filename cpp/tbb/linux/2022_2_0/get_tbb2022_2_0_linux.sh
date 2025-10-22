#!/bin/bash

# Script to download, extract, and install oneTBB v2022.2.0 on Ubuntu 24.04
# Assumes Ubuntu 24.04 with basic tools installed. Run as non-root user.
# Prerequisites: sudo access, internet connection, ~200MB free space.

set -e  # Exit on any error

# Variables
TBB_VERSION="2022.2.0"
TBB_URL="https://github.com/uxlfoundation/oneTBB/releases/download/v${TBB_VERSION}/oneapi-tbb-${TBB_VERSION}-lin.tgz"
TBB_DIR="oneapi-tbb-${TBB_VERSION}-lin"
INSTALL_PREFIX="/usr/local"  # Change if desired, e.g., "$HOME/.local"

echo "Starting oneTBB ${TBB_VERSION} installation on Ubuntu 24.04..."

# Step 1: Update package list and install prerequisites
echo "Updating system and installing prerequisites..."
sudo apt update
sudo apt install -y wget build-essential cmake pkg-config libicu-dev

# Step 2: Download the tarball
echo "Downloading oneTBB tarball..."
wget -O oneapi-tbb-${TBB_VERSION}-lin.tgz "${TBB_URL}"

# Step 3: Extract the tarball
echo "Extracting tarball..."
tar -xzf oneapi-tbb-${TBB_VERSION}-lin.tgz
cd "${TBB_DIR}"

# Step 4: Create build directory and configure with CMake
echo "Configuring build with CMake..."
mkdir build
cd build
cmake .. \
    -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DTBB_TEST=OFF \
    -DTBB_STRICT=OFF \
    -DCMAKE_CXX_COMPILER=g++  # Use g++ for Ubuntu default

# Step 5: Compile (use -j$(nproc) for parallel build if desired)
echo "Compiling oneTBB..."
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

# Optional: Set environment variables (add to ~/.bashrc for persistence)
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

echo "Installation complete! oneTBB is installed to ${INSTALL_PREFIX}."
echo "Run 'source ~/.bashrc' in new terminals or restart your shell."
echo "Verify with: pkg-config --modversion tbb"
