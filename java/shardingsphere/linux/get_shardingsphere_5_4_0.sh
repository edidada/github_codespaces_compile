#! /bin/bash
cd "$(dirname "$0")"
git clone -b 5.4.1 https://github.com/apache/shardingsphere.git
cd shardingsphere
./mvnw clean package -DskipTests