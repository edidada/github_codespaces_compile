#!/bin/bash
sudo apt-get update
sudo apt-get install -y build-essential libssl-dev zlib1g-dev libreadline-dev libyaml-dev libsqlite3-dev llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python-openssl git
git clone https://github.com/openssl/openssl.git
cd openssl
git checkout OpenSSL_1_1_1o
./config --prefix=/usr/local/openssl --openssldir=/usr/local/openssl shared zlib enable-camellia enable-idea enable-seed enable-sm2 enable-sm4 enable-tls13 enable-weak-ssl-ciphers no-comp no-dso no-hw no-mdc2 no-rc5 no-rfc3779 no-sctp no-ssl-trace no-zlib no-tests
make
sudo make install
sudo ldconfig
