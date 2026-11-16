#! /usr/bin/env bash
#
# OpenCV 4.13.0 源码编译（C++ 核心 + Python3 绑定 cv2）：
#   git clone tag 4.13.0 -> cmake 配置（关闭测试/示例，开启 BUILD_opencv_python3）
#   -> cmake --build。验证产物：cv2.*.so 存在且可 import。
set -euo pipefail
cd "$(dirname "$0")"
rm -rf opencv
git clone --quiet --depth=1 -b 4.13.0 https://github.com/opencv/opencv.git

echo "== configure =="
cmake -S opencv -B opencv/build \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_TESTS=OFF \
  -DBUILD_PERF_TESTS=OFF \
  -DBUILD_EXAMPLES=OFF \
  -DBUILD_opencv_python3=ON \
  -DPYTHON3_EXECUTABLE="$(command -v python3)" \
  -DWITH_QT=OFF \
  -DWITH_OPENGL=OFF

echo "== build =="
cmake --build opencv/build --parallel 2

echo "== verify =="
cv2so="$(find opencv/build -name 'cv2.*.so' | head -1)"
[ -n "$cv2so" ] || { echo "FATAL: 没找到 cv2 扩展" >&2; exit 1; }
PYTHONPATH="$(dirname "$cv2so")" python3 -c "import cv2; print('PASS cv2', cv2.__version__)"
echo "PASS: OpenCV 4.13.0 源码编译完成（cv2=$cv2so）"
