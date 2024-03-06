#! /bin/bash
cd "$(dirname "$0")"
sudo apt update
git clone -b 2.4.0 https://git.codesynthesis.com/odb/libodb.git
cd libodb
sudo apt-get install gcc-10-plugin-dev
./bootstrap
./configure
make
sudo make install
cd ../
git clone -b 2.4.0 https://git.codesynthesis.com/odb/odb.git
cd odb
./bootstrap
./configure
make
sudo make install
cd ../
git clone -b 2.4.0 https://git.codesynthesis.com/odb/libodb-mysql.git
cd libodb-mysql
./bootstrap
./configure
make
sudo make install
cd ../
git clone -b 2.4.0 https://git.codesynthesis.com/odb/odb-examples.git
cd odb-examples
./bootstrap
./configure
make
sudo make install