#! /bin/bash
cd "$(dirname "$0")"
git clone https://github.com/ryenus/hsqldb.git -b 2.7.2
cd hsqldb
cd build
gradle build