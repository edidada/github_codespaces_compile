#! /bin/bash
git clone https://github.com/kaldi-asr/kaldi.git -b 5.4
cd kaldi
sudo apt update
sudo apt-get install  sox subversion libatlas3-base -y
#sudo apt-get install  g++ zlib1g-dev make automake autoconf bzip2 unzip wget sox libtool subversion python2.7 python3 libatlas-dev libatlas-base-dev -y
cd tools && extras/check_dependencies.sh
make
extras/install_irstlm.sh