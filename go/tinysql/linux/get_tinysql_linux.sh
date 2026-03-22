#! /bin/bash
cd "$(dirname "$0")"
git clone -b course https://github.com/talent-plan/tinysql.git
cd tinysql
make
