#! /bin/bash
cd "$(dirname "$0")"
git clone -b v3.4.0 https://github.com/apache/spark.git
cd spark
mvn clean package  -DskipTests
