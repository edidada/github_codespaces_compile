#! /bin/bash
cd "$(dirname "$0")"
brew update
brew install autoconf automake libtool wxwidgets gnutls dbus gtk+3 sqlite gettext svn
mkdir -p "$HOME/prefix"
mkdir -p "$HOME/src"
export CC="clang -mmacosx-version-min=10.13"
export CXX="clang++ -std=c++17 -stdlib=libc++ -mmacosx-version-min=10.13"
export OBJC="clang -mmacosx-version-min=10.13"
export OBJCXX="clang++ -std=c++17 -stdlib=libc++ -mmacosx-version-min=10.13"
export AS="as -mmacosx-version-min=10.13"
export LD="ld -macosx_version_min 10.13"
export PATH="$HOME/prefix/bin:$PATH"
export CPPFLAGS="-I$HOME/prefix/include"
export LDFLAGS="-L$HOME/prefix/lib"
export LD_LIBRARY_PATH="$HOME/prefix/lib"
export PKG_CONFIG_PATH="$HOME/prefix/lib/pkgconfig"
curl -OL https://download.filezilla-project.org/libfilezilla/libfilezilla-0.41.1.tar.bz2
tar xf libfilezilla-0.41.1.tar.bz2
cd libfilezilla-0.41.1
./configure --prefix="$HOME/prefix" --enable-shared --disable-static
make
make install
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