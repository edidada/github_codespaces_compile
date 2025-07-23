#!/bin/bash
sudo apt update
sudo apt install openjdk-21-jdk -y
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
echo "java version"
java --version
javac --version
sudo rm /etc/alternatives/java
sudo ln -s /usr/lib/jvm/java-21-openjdk-amd64/bin/java /etc/alternatives/java
sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-21-openjdk-amd64/bin/java 1
sudo update-alternatives --set java /usr/lib/jvm/java-21-openjdk-amd64/bin/java
sudo rm /etc/alternatives/javac
sudo ln -s /usr/lib/jvm/java-21-openjdk-amd64/bin/javac /etc/alternatives/javac
sudo update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/java-21-openjdk-amd64/bin/javac 1
sudo update-alternatives --set javac /usr/lib/jvm/java-21-openjdk-amd64/bin/javac
echo "java version"
java --version
javac --version
cd "$(dirname "$0")"
wget https://github.com/bazelbuild/bazel/releases/download/7.0.0/bazel-7.0.0-dist.zip
unzip bazel-7.0.0-dist.zip -d ./bazel-7.0.0-dist
cd bazel-7.0.0-dist
chmod +x compile.sh
./compile.sh