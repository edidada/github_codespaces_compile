#! /bin/bash
cd "$(dirname "$0")"
wget -O wxWidgets-3.0.4.zip https://github.com/wxWidgets/wxWidgets/releases/download/v3.0.4/wxWidgets-3.0.4.zip
unzip wxWidgets-3.0.4.zip -d ./wxWidgets-3.0.4
cd ./wxWidgets-3.0.4
./configure --prefix=/usr/local
make -j$(nproc)
sudo make install
cd ../