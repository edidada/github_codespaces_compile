#! /bin/bash
cd "$(dirname "$0")"
git clone -b 7.4.2 https://github.com/redis/redis.git
cd redis
make
make test
sudo make install