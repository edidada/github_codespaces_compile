#!/bin/bash
cd "$(dirname "$0")"
git clone https://github.com/langchain4j/langchain4j.git
cd langchain4j
git checkout 1.4.0
which java
java -version
which mvn
mvn -version
mvn clean package
