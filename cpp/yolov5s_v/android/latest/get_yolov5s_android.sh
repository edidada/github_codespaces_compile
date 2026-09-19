#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
sudo apt-get update
git clone --recursive https://github.com/lp6m/yolov5s_android
cd yolov5s_android
sed -i 's|nvidia/cuda:10.2-cudnn8-devel-ubuntu18.04|nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04|' docker/Dockerfile
docker build . -f docker/Dockerfile -t yolov5s_android
