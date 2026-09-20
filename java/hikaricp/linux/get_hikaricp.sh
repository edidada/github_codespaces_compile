#! /bin/bash
cd "$(dirname "$0")"
git clone -b HikariCP-4.0.3 https://github.com/brettwooldridge/HikariCP.git
cd HikariCP
mvn clean package  -DskipTests
