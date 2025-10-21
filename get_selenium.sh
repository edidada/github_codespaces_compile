#! /bin/bash
cd "$(dirname "$0")"
sudo apt update
sudo apt install default-jdk maven git
git clone -b selenium-4.15.0 https://github.com/seleniumhq/selenium.git
cd selenium
mvn clean install