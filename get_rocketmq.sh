#! /bin/bash
git clone https://github.com/apache/rocketmq.git
cd rocketmq
git checkout rocketmq-all-4.3.0
mvn clean package