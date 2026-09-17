#! /bin/bash
git clone https://github.com/edidada/nacos.git
cd nacos
git checkout 1.4.2
find . -name pom.xml -exec sed -i -e 's#<source>1.6</source>#<source>1.8</source>#g' -e 's#<target>1.6</target>#<target>1.8</target>#g' -e 's#<maven.compiler.source>1.6</maven.compiler.source>#<maven.compiler.source>1.8</maven.compiler.source>#g' -e 's#<maven.compiler.target>1.6</maven.compiler.target>#<maven.compiler.target>1.8</maven.compiler.target>#g' {} +
mvn -Prelease-nacos -Dmaven.test.skip=true -Dmaven.compiler.source=1.8 -Dmaven.compiler.target=1.8 install -U
