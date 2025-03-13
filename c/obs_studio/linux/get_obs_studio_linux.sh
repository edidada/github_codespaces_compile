#! /bin/bash
cd "$(dirname "$0")"
sudo apt update
sudo apt install -y mesa-utils
glxinfo | grep "OpenGL"
sudo apt install -y v4l2loopback-dkms
sudo apt install -y cmake ninja-build pkg-config clang clang-format build-essential curl ccache git zsh
sudo apt install -y libavcodec-dev libavdevice-dev libavfilter-dev libavformat-dev libavutil-dev libswresample-dev libswscale-dev libx264-dev libcurl4-openssl-dev libmbedtls-dev libgl1-mesa-dev libjansson-dev libluajit-5.1-dev python3-dev libx11-dev libxcb-randr0-dev libxcb-shm0-dev libxcb-xinerama0-dev libxcb-composite0-dev libxcomposite-dev libxinerama-dev libxcb1-dev libx11-xcb-dev libxcb-xfixes0-dev swig libcmocka-dev libxss-dev libglvnd-dev libgles2-mesa-dev libwayland-dev librist-dev libsrt-openssl-dev libpci-dev libpipewire-0.3-dev libqrcodegencpp-dev uthash-dev
#sudo apt install -y \
#       qt6-base-dev \
#       qt6-base-private-dev \
#       qt6-svg-dev \
#       qt6-wayland \
#       qt6-image-formats-plugins
#sudo apt install -y \
#       libasound2-dev \
#       libfdk-aac-dev \
#       libfontconfig-dev \
#       libfreetype6-dev \
#       libjack-jackd2-dev \
#       libpulse-dev libsndio-dev \
#       libspeexdsp-dev \
#       libudev-dev \
#       libv4l-dev \
#       libva-dev \
#       libvlc-dev \
#       libvpl-dev \
#       libdrm-dev \
#       nlohmann-json3-dev \
#       libwebsocketpp-dev \
#       libasio-dev
sudo apt install -y qt6-base-dev qt6-base-private-dev qt6-svg-dev qt6-wayland qt6-image-formats-plugins libasound2-dev libfdk-aac-dev libfontconfig-dev libfreetype6-dev libjack-jackd2-dev libpulse-dev libsndio-dev libspeexdsp-dev libudev-dev libv4l-dev libva-dev libvlc-dev libvpl-dev libdrm-dev nlohmann-json3-dev libwebsocketpp-dev libasio-dev
sudo add-apt-repository ppa:savoury1/ffmpeg4
sudo add-apt-repository ppa:savoury1/ffmpeg7
sudo apt-get update
sudo apt-get upgrade && sudo apt-get dist-upgrade
sudo apt-get install -y ffmpeg
git clone --recursive https://github.com/obsproject/obs-studio.git
cd obs-studio
mkdir build
cd build
cmake -DUNIX_STRUCTURE=1 -DCMAKE_INSTALL_PREFIX=/usr ..
make -j4