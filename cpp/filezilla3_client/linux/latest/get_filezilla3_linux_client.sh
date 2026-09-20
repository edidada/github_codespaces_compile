#! /bin/bash
cd "$(dirname "$0")"
sudo apt update
sudo apt-get install libfilezilla-dev libwxbase3.0-dev gnutls-dev libdbus-1-dev libwxgtk3.0-gtk3-dev  libgtk-3-dev libsqlite3-dev gettext -y
svn co https://svn.filezilla-project.org/svn/FileZilla3/tags/3.56.0/ fz
cd fz
autoreconf -i
CXXFLAGS="-include cstdint -O2 -g" ./configure --with-pugixml=builtin
make -j4
sudo make install