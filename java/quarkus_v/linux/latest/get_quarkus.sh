#! /bin/bash
set -euo pipefail
sudo apt-get update
sudo apt-get install -y openjdk-17-jdk
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
export PATH="$JAVA_HOME/bin:$PATH"
cd "$(dirname "$0")"
git clone -b 3.8.1 https://github.com/quarkusio/quarkus.git
cd quarkus
./mvnw clean install -DskipTests
