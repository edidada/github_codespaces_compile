#! /bin/bash
cd "$(dirname "$0")"
git clone -b v2.1.4 https://github.com/eclipse-vertx/vert.x.git
cd vert.x
for attempt in 1 2 3; do
  ./gradlew build -x test -x integrationTest && exit 0
  rm -rf "$HOME/.gradle/wrapper/dists/gradle-1.7-bin"
done
exit 1
