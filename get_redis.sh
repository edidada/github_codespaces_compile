#! /bin/bash
cd "$(dirname "$0")"
git clone -b 5.0.14 https://github.com/redis/redis.git
cd redis
make
make test