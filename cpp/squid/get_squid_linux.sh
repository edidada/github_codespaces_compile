#! /bin/bash
cd "$(dirname "$0")"
sudo apt update
sudo apt install -y autoconf automake libtool libltdl-dev
git clone -b SQUID_7_0_1 https://github.com/squid-cache/squid.git
cd squid
chmod +x bootstrap.sh
./bootstrap.sh