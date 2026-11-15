#! /bin/bash
sudo apt update
sudo apt install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libsqlite3-dev libreadline-dev libffi-dev libbz2-dev -y
wget https://www.python.org/ftp/python/3.15.2/Python-3.15.2.tgz
tar -xf Python-3.15.2.tgz
cd Python-3.15.2
# 3.15 已无 --without-tests（configure.ac 中不存在该选项），去掉避免 unrecognized option
./configure --enable-optimizations
make -j 4
sudo make altinstall
python3.15 --version
sudo ln -s /usr/local/bin/python3.15 /usr/local/bin/python
export PATH=/usr/local/bin:$PATH
python --version