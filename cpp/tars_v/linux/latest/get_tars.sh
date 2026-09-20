#! /bin/bash
cd "$(dirname "$0")"
sudo update
sudo apt-get install build-essential bison flex cmake psmisc libncurses5-dev zlib1g-dev psmisc telnet net-tools wget unzip -y
wget https://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.26.tar.gz
tar -zxvf mysql-5.6.26.tar.gz
cd mysql-5.6.26/
cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysql-5.6.26 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DMYSQL_USER=mysql -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci
make
make install
git clone https://github.com/TarsCloud/TarsFramework.git --recursive
cd TarsFramework
git submodule update --remote --recursive
cd build
cmake ..
make -j4
