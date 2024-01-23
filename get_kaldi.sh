#! /bin/bash
git clone https://github.com/kaldi-asr/kaldi.git -b 5.4
cd kaldi
sudo apt update
sudo apt install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libsqlite3-dev libreadline-dev libffi-dev libbz2-dev -y
wget https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tgz
tar -xf Python-2.7.18.tgz
cd Python-2.7.18
./configure --enable-optimizations
make -j 4
sudo make altinstall
python2.7 --version
sudo ln -s /usr/local/bin/python2.7 /usr/local/bin/python
export PATH=/usr/local/bin:$PATH
python --version
cd ..
sudo apt-get install  sox subversion libatlas3-base -y
#sudo apt-get install  g++ zlib1g-dev make automake autoconf bzip2 unzip wget sox libtool subversion python2.7 python3 libatlas-dev libatlas-base-dev -y
cd tools && extras/check_dependencies.sh
make -j4
extras/install_irstlm.sh