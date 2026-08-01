#! /bin/bash
cd "$(dirname "$0")"
git clone -b v3.6.2 https://github.com/thingsboard/thingsboard.git
cd thingsboard
mvn clean package  -DskipTests
