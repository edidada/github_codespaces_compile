#! /bin/bash
cd "$(dirname "$0")"
git clone -b v2.1.4 https://github.com/eclipse-vertx/vert.x.git
cd vert.x
./gradlew build -x test -x integrationTest