#! /bin/bash
cd "$(dirname "$0")"
git clone -b v1.8.0 https://github.com/alibaba/Sentinel.git
cd Sentinel
mvn clean package  -DskipTests
