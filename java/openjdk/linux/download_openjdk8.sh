#! /bin/bash
# 添加 OpenJDK 7 PPA
sudo add-apt-repository ppa:openjdk-r/ppa -y
sudo apt-get update
# 安装 OpenJDK 7
# sudo apt-get install -y openjdk-7-jdk
# 设置环境变量
#echo "JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64" >> $GITHUB_ENV
#echo "/usr/lib/jvm/java-7-openjdk-amd64/bin" >> $GITHUB_PATH
echo "java -version"
java -version
mkdir -p ~/jdk
curl -L -o jdk-7u80-linux-x64.tar.gz \
      "https://github.com/edidada/github_codespaces_compile/releases/download/jdk-7u80-v1.0/jdk-7u80-linux-x64.tar.gz"
tar -xzf jdk-7u80-linux-x64.tar.gz -C ~/jdk
# 设置环境变量
echo "JAVA_HOME=~/jdk/jdk1.7.0_80" >> $GITHUB_ENV
export JAVA_HOME="$HOME/jdk/jdk1.7.0_80"
export PATH="$JAVA_HOME/bin:$PATH"
echo $PATH
echo "$JAVA_HOME/bin" >> $GITHUB_PATH
java -version
cd "$(dirname "$0")"
chmod +x build_openjdk8.sh
./build_openjdk8.sh