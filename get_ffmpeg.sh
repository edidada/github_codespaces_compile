#! /bin/bash
cd "$(dirname "$0")"
mkdir -p ffmpeg-samples
./configure --samples=ffmpeg-samples --cc=$CC
make -j 8
make fate-rsync
make check -j 8