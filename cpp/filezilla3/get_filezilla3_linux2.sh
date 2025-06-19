#! /bin/bash
cd "$(dirname "$0")"
wget -O wxWidgets-3.0.1.zip https://github.com/wxWidgets/wxWidgets/releases/download/v3.0.1/wxWidgets-3.0.1.zip
unzip wxWidgets-3.0.1.zip -d ./wxWidgets-3.0.1
cd ./wxWidgets-3.0.1
./configure
make -j$(nproc)
sudo make install
cd ../