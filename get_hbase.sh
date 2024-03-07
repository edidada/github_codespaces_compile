#! /bin/bash
cd "$(dirname "$0")"
git clone -b rel/2.5.7 https://github.com/apache/hbase.git
cd hbase
mvn clean install -DskipTests -Dhadoop.profile=3.0