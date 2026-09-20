#! /bin/bash
git clone https://github.com/alibaba/nacos.git
cd nacos
git checkout 2.4.3
mvn -Prelease-nacos -Dmaven.test.skip=true install -U