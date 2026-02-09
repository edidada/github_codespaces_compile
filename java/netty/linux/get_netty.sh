#! /bin/bash
cd "$(dirname "$0")"
sudo apt-get update
git clone -b netty-4.1.99.Final https://github.com/netty/netty.git
cd netty
sudo apt-get update
sudo apt-get install autoconf automake libtool make tar gcc
./mvnw install -DskipTests -T1C
