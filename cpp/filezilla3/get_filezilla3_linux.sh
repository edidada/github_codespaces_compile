#! /bin/bash
cd "$(dirname "$0")"
sudo add-apt-repository ppa:mhier/libboost-latest
sudo apt update
apt search libboost1
sudo apt install subversion libgtk2.0-dev libgtk-3-dev xdg-utils libboost1.81-all-dev libwxgtk3.0-gtk3-dev -y
echo "which svn"
which svn
export PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig:$PKG_CONFIG_PATH
pkg-config --exists gtk+-2.0 && echo "GTK+ 2 is available"
wget -O libfilezilla-0.50.0.tar.xz https://dl1.cdn.filezilla-project.org/libfilezilla/libfilezilla-0.50.0.tar.xz?h=_2qMQ6SfZVO0U0Z8Pll2RA&x=1743654277
tar -xvf libfilezilla-0.50.0.tar.xz
cd libfilezilla-0.50.0/
./configure --prefix=/usr/local
make -j$(nproc)
sudo make install
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
echo "libfilezilla"
pkg-config --modversion libfilezilla
cd ../
wget -O wxWidgets-3.2.1.zip https://github.com/wxWidgets/wxWidgets/releases/download/v3.2.1/wxWidgets-3.2.1.zip
unzip wxWidgets-3.2.1.zip -d ./wxWidgets-3.2.1
cd ./wxWidgets-3.2.1
./configure
make -j$(nproc)
sudo make install
cd ../
svn checkout https://svn.filezilla-project.org/svn/FileZilla3/trunk
cd FileZilla3
autoreconf --install --force --verbose
mkdir compile
cd compile
../configure
make -j$(nproc)