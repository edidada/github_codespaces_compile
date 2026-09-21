#! /bin/bash
cd "$(dirname "$0")"
git clone -b v2.1.4 https://github.com/eclipse-vertx/vert.x.git
cd vert.x
sed -i 's#http#https#g' gradle/wrapper/gradle-wrapper.properties
find . -type f \( -name '*.gradle' -o -name 'pom.xml' \) -exec sed -i 's#http://#https://#g' {} +
sed -i 's#http://#https://#g' build.gradle settings.gradle 2>/dev/null || true
sed -i "s#mavenCentral()#maven { url 'https://repo.maven.apache.org/maven2' }#g" build.gradle
grep -RIl 'http://' . | xargs -r sed -i 's#http://#https://#g'
find . -type f -exec sed -i 's#http://repo1.maven.org#https://repo1.maven.org#g' {} +
for attempt in 1 2 3; do
  ./gradlew build -x test && exit 0
  rm -rf "$HOME/.gradle/wrapper/dists/gradle-1.7-bin"
done
exit 1
