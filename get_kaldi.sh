#! /bin/bash
git clone https://github.com/kaldi-asr/kaldi.git -b 5.4
cd kaldi
chmod +x ./INSTALL
./INSTALL
cd tools && extras/check_dependencies.sh
sudo apt-get install  g++ zlib1g-dev make automake autoconf bzip2 unzip wget sox libtool subversion python2.7 python3 libatlas-dev libatlas-base-dev -y
make
extras/install_irstlm.sh