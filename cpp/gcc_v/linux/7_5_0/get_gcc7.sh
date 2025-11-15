#! /bin/bash
echo "=== 使用源码编译的 GCC 7.5.0 编译项目 ==="

# 启用新编译器
source ~/.bashrc

# 验证编译器
echo "当前 GCC 版本:"
gcc --version
echo "当前 G++ 版本:"
g++ --version

# 设置项目目录
PROJECT_DIR="/tmp/tmp.kELYPgeEOp/playscript-cpp"
BUILD_DIR="$PROJECT_DIR/cmake-build-debug-gcc7"

# 创建构建目录
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# 使用 CMake 配置项目
cmake "$PROJECT_DIR" \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_C_COMPILER=/usr/local/gcc-7.5.0/bin/gcc \
  -DCMAKE_CXX_COMPILER=/usr/local/gcc-7.5.0/bin/g++ \
  -DCMAKE_CXX_STANDARD=11 \
  -DCMAKE_CXX_STANDARD_REQUIRED=ON \
  -DCMAKE_CXX_FLAGS="-std=c++11" \
  -DLLVM_DIR=/usr/lib/llvm-7/lib/cmake/llvm \
  -DLLVM_USE_STATIC_LIBS=OFF

# 编译项目
echo "=== 开始编译项目 ==="
make -j$(nproc)

echo "✅ 项目编译完成"