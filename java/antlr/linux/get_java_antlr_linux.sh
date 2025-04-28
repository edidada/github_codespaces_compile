#!/bin/bash
cd "$(dirname "$0")"
git clone https://github.com/antlr/antlr4.git
cd antlr
git checkout 4.13.2
cd tool
mvn clean package