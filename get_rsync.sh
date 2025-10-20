#! /bin/bash
wget --no-check-certificate https://download.samba.org/pub/rsync/src/rsync-3.2.7.tar.gz -O rsync-3.2.7.tar.gz
tar -zxvf rsync-3.2.7.tar.gz
cd rsync-3.2.7
sudo update
sudo apt install -y gcc g++ gawk autoconf automake python3-cmarkgfm acl libacl1-dev attr libattr1-dev libxxhash-dev libzstd-dev liblz4-dev libssl-dev
./configure
make
sudo make install