#! /bin/bash
cd "$(dirname "$0")"
sudo apt update
git clone https://github.com/duckdb/duckdb.git
cd duckdb
git checkout v1.4.3
make debug
