#! /bin/bash
cd "$(dirname "$0")"
git clone -b 6.2.17 https://github.com/redis/redis.git
cd redis
make
make test
sudo make install