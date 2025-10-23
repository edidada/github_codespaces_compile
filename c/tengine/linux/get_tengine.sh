#! /bin/bash
cd "$(dirname "$0")"
sudo apt-get update
sudo apt install -y initscripts libc-bin libgd2-xpm-dev libgeoip-dev libxslt1-dev libpcre++0 libpcre++-dev liblua5.1-0-dev libssl-dev lua5.1 openssl passwd libperl-dev libxml2 libxml2-dev libxslt1-dev libxslt-dev
git config advice.detachedHead false
# 设置环境变量让 configure 能找到库
export XML2_CFLAGS="-I/usr/include/libxml2"
export XML2_LIBS="-lxml2"
export XSLT_CFLAGS="-I/usr/include/libxslt"
export XSLT_LIBS="-lxslt"
git clone -b tengine-2.2.2 https://github.com/alibaba/tengine.git
cd tengine
./configure --enable-mods-static=all --with-ipv6 --with-http_v2_module --without-http_xslt_module
sudo make install