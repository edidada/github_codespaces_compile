#! /bin/bash
cd "$(dirname "$0")"
git clone -b v3.3.3 https://github.com/alibaba/easyexcel.git
cd easyexcel
./mvnw clean package  -DskipTests
