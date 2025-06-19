#! /bin/bash
cd "$(dirname "$0")"
sudo add-apt-repository ppa:mhier/libboost-latest
sudo apt update
apt search libboost1
apt search libwxgtk
sudo apt install subversion nettle-dev libpugixml-dev libgnutls28-dev libgtk2.0-dev libgtk-3-dev xdg-utils libboost1.83-all-dev -y
echo "which svn"
which svn
export PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig:$PKG_CONFIG_PATH
pkg-config --exists gtk+-2.0 && echo "GTK+ 2 is available"
pkg-config gtk+-2.0 --libs