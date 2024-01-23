#! /bin/bash
sudo apt update
sudo apt install libevent-dev -y
dpkg -L libevent-dev | grep LibeventConfig.cmake
git clone https://github.com/oceanbase/miniob.git
cd miniob
bash build.sh init
bash build.sh release