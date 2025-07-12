#! /bin/bash
cd "$(dirname "$0")"
git clone -b v3.5.1 https://github.com/apache/spark.git
cd spark
./build/mvn -DskipTests clean package