#! /bin/bash
sudo apt update
sudo apt-get install curl python3 python3-pip -y
python3 -m pip install --user mercurial
echo 'export PATH="'"$(python3 -m site --user-base)"'/bin:$PATH"' >> ~/.bashrc
curl https://hg.mozilla.org/mozilla-central/raw-file/default/python/mozboot/bin/bootstrap.py -O
python3 bootstrap.py
cd mozilla-unified
hg up -C central
./mach build