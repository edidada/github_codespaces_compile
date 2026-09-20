#! /bin/bash
cd "$(dirname "$0")"
git clone -b 3.4.0 https://github.com/apache/kafka.git
cd kafka
./gradlew clean releaseTarGz -x test -x integrationTest
