#! /bin/bash
cd "$(dirname "$0")"
git clone -b HikariCP-4.0.3 https://github.com/brettwooldridge/HikariCP.git
cd HikariCP
mkdir -p "$HOME/.m2"
cat > "$HOME/.m2/toolchains.xml" <<EOF
<toolchains>
  <toolchain>
    <type>paths</type>
    <provides><id>java</id></provides>
    <configuration><paths><path>${JAVA_HOME}</path></paths></configuration>
  </toolchain>
</toolchains>
EOF
mvn clean package  -DskipTests
