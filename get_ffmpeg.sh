#! /bin/bash
cd "$(dirname "$0")"
wget --no-check-certificate https://github.com/FFmpeg/FFmpeg/archive/refs/tags/n6.1.1.tar.gz -O n6.1.1.tar.gz
tar -zxvf n6.1.1.tar.gz
cd FFmpeg*
mkdir -p ffmpeg-samples
./configure --samples=ffmpeg-samples --cc=$CC --disable-x86asm
make -j 8
make fate-rsync
#make check -j 8