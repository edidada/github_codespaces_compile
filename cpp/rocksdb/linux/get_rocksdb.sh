#!/bin/bash
cd "$(dirname "$0")"
git clone https://github.com/facebook/rocksdb.git
cd rocksdb
make
