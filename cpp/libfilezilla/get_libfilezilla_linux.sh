#! /bin/bash
cd "$(dirname "$0")"/libboost-latest
sudo apt update
apt search libboost1
apt search libwxgtk
sudo apt install subversion libgtk2.0-dev libgtk-3-dev xdg-utils libboost1.83-all-dev libwxgtk3.2-dev -y
echo "which svn"
which svn
export PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig:$PKG_CONFIG_PATH
pkg-config --exists gtk+-2.0 && echo "GTK+ 2 is available"
pkg-config gtk+-2.0 --libs
wget -O libfilezilla-0.50.0.tar.xz https://dl3.cdn.filezilla-project.org/libfilezilla/libfilezilla-0.50.0.tar.xz?h=Lafu1Ycp6g8ABpHqaShf2w&x=1750312053
echo "which libfilezilla"
ls -la
tar -xvf libfilezilla-0.50.0.tar.xz
cd libfilezilla-0.50.0/
./configure --prefix=/usr/local
make -j$(nproc)
sudo make install
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
echo "libfilezilla"
pkg-config --modversion libfilezilla