#! /bin/bash
cd "$(dirname "$0")"
sudo apt-get update
wget https://dlcdn.apache.org/tomcat/tomcat-8/v8.5.99/src/apache-tomcat-8.5.99-src.zip -O apache-tomcat-8.5.99-src.zip
unzip apache-tomcat-8.5.99-src.zip
cd apache*
ant ide-eclipse