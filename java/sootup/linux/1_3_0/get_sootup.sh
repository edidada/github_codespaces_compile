#!/bin/bash
cd "$(dirname "$0")"
git clone https://github.com/soot-oss/SootUp.git
cd SootUp
git checkout v1.3.0
mvn clean install