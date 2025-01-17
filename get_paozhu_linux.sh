#! /bin/bash
cd "$(dirname "$0")"
sudo apt-get -y update
sudo apt-get install cmake -y
sudo apt-get install -y brotli  libbrotli-dev zlib1g-dev
sudo apt-get install libgd-dev -y
sudo apt-get install qrencode libqrencode-dev -y
sudo apt-get install openssl libssl-dev -y
sudo apt-get install mysql-server -y
sudo apt-get install mysql-common -y
sudo apt-get install mysql-client -y
sudo apt-get install libmysqlclient-dev -y
git clone https://github.com/hggq/paozhu.git
cd paozhu
unzip asio.zip
mkdir build
cd build
cmake ..
make