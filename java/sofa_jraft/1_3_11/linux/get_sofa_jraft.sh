#! /bin/bash
cd "$(dirname "$0")"
git clone https://github.com/sofastack/sofa-jraft.git
cd sofa-jraft
git checkout 1.3.11
mvn clean compile -DskipTests
