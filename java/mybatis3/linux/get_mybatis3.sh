#! /bin/bash
cd "$(dirname "$0")"
git clone -b mybatis-3.4.6 https://github.com/mybatis/mybatis-3.git
cd mybatis-3
./mvnw clean package  -DskipTests
