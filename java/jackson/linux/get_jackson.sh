#! /bin/bash
cd "$(dirname "$0")"
git checkout -b 2.16 https://github.com/FasterXML/jackson-databind.git
cd jackson-databind
./mvnw clean package  -DskipTests
cd ../
git checkout -b 2.16 https://github.com/FasterXML/jackson-core.git
cd jackson-core
./mvnw clean package  -DskipTests
cd ../
git checkout -b 2.16 https://github.com/FasterXML/jackson-annotations.git
cd jackson-annotations
./mvnw clean package  -DskipTests
