#! /bin/bash
cd "$(dirname "$0")"
git clone -b v25.0.3 https://github.com/moby/moby.git
cd moby
make -j5