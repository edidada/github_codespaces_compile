#! /bin/bash
cd "$(dirname "$0")"
wget --no-check-certificate https://github.com/FFmpeg/FFmpeg/archive/refs/tags/n6.1.1.tar.gz -O n6.1.1.tar.gz
tar -zxvf n6.1.1.tar.gz
cd FFmpeg*
mkdir -p ffmpeg-samples
./configure --help
sudo apt install libxvidcore-dev libx264-dev libx265-dev libwebp-dev libvpx-dev libvorbis-dev libopus-dev libmp3lame-dev libass-dev libfdk-aac-dev -y
./configure  --prefix=/usr/local/ffmpeg --enable-gpl --enable-libx264 --enable-libx265 --enable-libvpx --enable-libfdk-aac --enable-libmp3lame --enable-libopus --enable-libvorbis --enable-libxvid --enable-libass --enable-libwebp --enable-nonfree --disable-x86asm
#./configure --prefix=/usr/local/ffmpeg --samples=ffmpeg-samples --cc=$CC --disable-x86asm
make -j 8
make fate-rsync
sudo make install
#make check -j 8