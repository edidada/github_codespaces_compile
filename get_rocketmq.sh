#! /bin/bash
git clone https://github.com/apache/rocketmq.git
cd rocketmq
git checkout rocketmq-all-4.3.0
mvn clean package
mvn -B clean apache-rat:check
mvn -B package jacoco:report coveralls:report
mvn clean install -Pit-test
mvn sonar:sonar -Psonar-apache