#! /bin/bash
# 添加 OpenJDK 7 PPA
sudo add-apt-repository ppa:openjdk-r/ppa -y
sudo apt-get update
# 安装 OpenJDK 7
sudo apt-get install -y openjdk-7-jdk
# 设置环境变量
echo "JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64" >> $GITHUB_ENV
echo "/usr/lib/jvm/java-7-openjdk-amd64/bin" >> $GITHUB_PATH
java -version
mkdir -p ~/jdk
# 第一步：获取 Cookie 和 AuthParam（模拟浏览器访问许可页面）
wget --no-check-certificate \
     --save-cookies cookies.txt \
     --keep-session-cookies \
     --no-cookies \
     --header="User-Agent: Mozilla/5.0" \
     "https://edelivery.oracle.com/otn-pub/java/jdk/7u80-b15/jdk-7u80-linux-x64.tar.gz" \
     -O /dev/null
# 第二步：使用保存的 Cookie 下载真实文件
wget --load-cookies cookies.txt \
     --no-check-certificate \
     --header="User-Agent: Mozilla/5.0" \
     "https://download.oracle.com/otn-pub/java/jdk/7u80-b15/jdk-7u80-linux-x64.tar.gz" \
     -O jdk-7u80-linux-x64.tar.gz
# 验证下载
ls -lh jdk-7u80-linux-x64.tar.gz
[ -s jdk-7u80-linux-x64.tar.gz ] || (echo "Download failed!" && exit 1)
# 解压
tar -xzf jdk-7u80-linux-x64.tar.gz -C ~/jdk --strip-components=1
# 清理
rm -f cookies.txt jdk-7u80-linux-x64.tar.gz
# 设置环境变量
echo "JAVA_HOME=~/jdk" >> $GITHUB_ENV
echo "$JAVA_HOME/bin" >> $GITHUB_PATH