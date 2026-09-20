#! /bin/bash
cd "$(dirname "$0")"
git clone -b REL_5_2_5 https://github.com/apache/poi.git
cd poi
./gradlew build -x test
