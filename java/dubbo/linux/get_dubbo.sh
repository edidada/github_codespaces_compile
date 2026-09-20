#! /bin/bash
cd "$(dirname "$0")"
git clone -b 3.2 https://github.com/apache/dubbo.git
cd dubbo
./mvnw clean package  -DskipTests