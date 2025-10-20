#! /bin/bash
# 创建安装目录
mkdir -p ~/jdk

# 下载 tar.gz 文件（wget 会自动跟随重定向，但可能需处理 cookie/许可）
wget --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" \
     https://download.oracle.com/otn-pub/java/jdk/7u80-b15/jdk-7u80-linux-x64.tar.gz \
     -O jdk-7u80-linux-x64.tar.gz

# 验证下载（可选，检查文件大小）
ls -lh jdk-7u80-linux-x64.tar.gz

# 解压到指定目录
tar -xzf jdk-7u80-linux-x64.tar.gz -C ~/jdk --strip-components=1

# 设置 JAVA_HOME 和 PATH（可选，用于后续步骤）
echo "JAVA_HOME=~/jdk" >> $GITHUB_ENV
echo "$JAVA_HOME/bin" >> $GITHUB_PATH
~/jdk/bin/java -version
# 输出应显示 openjdk version "1.7.0_80" 或类似
