#! /bin/bash
wget https://github.com/wg/wrk/archive/refs/tags/4.2.0.tar.gz
tar -zxvf 4.2.0.tar.gz
cd wrk-4.2.0/
make -j4