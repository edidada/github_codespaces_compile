#!/bin/bash
cd "$(dirname "$0")"
git clone https://github.com/antlr/stringtemplate4.git
cd stringtemplate4
git checkout ST4-4.3.4
mvn clean package
ls target -la