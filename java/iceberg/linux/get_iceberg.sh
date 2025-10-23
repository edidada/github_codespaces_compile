#! /bin/bash
cd "$(dirname "$0")"
sudo apt-get update
git clone -b apache-iceberg-1.4.2 https://github.com/apache/iceberg.git
cd iceberg
./gradlew build -x test -x integrationTest