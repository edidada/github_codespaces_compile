#! /bin/bash
cd "$(dirname "$0")"
git clone -b 1.2.20 https://github.com/alibaba/druid.git
cd druid
./mvnw clean package  -DskipTests