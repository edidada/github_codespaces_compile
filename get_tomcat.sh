#! /bin/bash
cd "$(dirname "$0")"
sudo apt-get update
wget http://mirror.bit.edu.cn/apache/tomcat/tomcat-8/v8.5.15/src/apache-tomcat-8.5.15-src.zip -O apache-tomcat-8.5.15-src.zip
unzip apache-tomcat-8.5.15-src.zip
cd apache*
ant ide-eclipse