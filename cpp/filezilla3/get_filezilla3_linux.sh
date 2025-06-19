#! /bin/bash
cd "$(dirname "$0")"
sudo add-apt-repository ppa:mhier/libboost-latest
sudo apt update
apt search libboost1
sudo apt install libboost1.81-all-dev -y
wget -O libfilezilla-0.50.0.tar.xz https://dl1.cdn.filezilla-project.org/libfilezilla/libfilezilla-0.50.0.tar.xz?h=_2qMQ6SfZVO0U0Z8Pll2RA&x=1743654277
tar -xvf libfilezilla-0.50.0.tar.xz
cd libfilezilla-0.50.0/
./configure --prefix=/usr/local
make -j$(nproc)
sudo make install
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
pkg-config --modversion libfilezilla
cd "$(dirname "$0")"
wget -O wxWidgets-3.2.1.zip https://github.com/wxWidgets/wxWidgets/releases/download/v3.2.1/wxWidgets-3.2.1.zip
unzip wxWidgets-3.2.1.zip -d ./wxWidgets-3.2.1
cd ./wxWidgets-3.2.1
./configure --with-wx-config=/usr/local/bin/wx-config
make -j$(nproc)
sudo make install
cd "$(dirname "$0")"
svn checkout https://svn.filezilla-project.org/svn/FileZilla3/trunk
cd FileZilla3
autoreconf --install --force --verbose
mkdir compile
cd compile
../configure
make -j$(nproc)