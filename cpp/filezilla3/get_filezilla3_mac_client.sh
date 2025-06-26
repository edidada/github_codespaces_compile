#! /bin/bash
cd "$(dirname "$0")"
brew update
brew install libdill
brew install libfilezilla wxwidgets gnutls dbus gtk+3 sqlite gettext svn
# 确保找到 Homebrew 的库和头文件
export PKG_CONFIG_PATH="/opt/homebrew/opt/openssl@3/lib/pkgconfig:/opt/homebrew/opt/sqlite/lib/pkgconfig:/opt/homebrew/opt/gnutls/lib/pkgconfig:$PKG_CONFIG_PATH"
export LDFLAGS="-L/opt/homebrew/opt/gnutls/lib -L/opt/homebrew/opt/sqlite/lib -L/opt/homebrew/opt/gettext/lib"
export CPPFLAGS="-I/opt/homebrew/opt/gnutls/include -I/opt/homebrew/opt/sqlite/include -I/opt/homebrew/opt/gettext/include"
svn co https://svn.filezilla-project.org/svn/FileZilla3/tags/3.56.0/ fz
cd fz
autoreconf -i
CXXFLAGS="-include cstdint -O2 -g" ./configure --with-pugixml=builtin
make -j4
sudo make install