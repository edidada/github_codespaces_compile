#! /bin/bash
sudo apt update
sudo apt install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libsqlite3-dev libreadline-dev libffi-dev libbz2-dev -y
wget https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tgz
tar -xf Python-2.7.18.tgz
cd Python-2.7.18
./configure --enable-optimizations --without-tests
make -j 4
sudo make altinstall
python2.7 --version
sudo ln -s /usr/local/bin/python2.7 /usr/local/bin/python
export PATH=/usr/local/bin:$PATH
python --version