#! /bin/bash
cd "$(dirname "$0")"
sudo apt-get update
wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.98/src/apache-tomcat-9.0.98-src.zip -O apache-tomcat-9.0.98-src.zip
unzip apache-tomcat-9.0.98-src.zip
cd apache*
ant ide-eclipse