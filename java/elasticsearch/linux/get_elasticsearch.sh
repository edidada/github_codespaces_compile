#! /bin/bash
git clone https://github.com/elastic/elasticsearch.git
cd elasticsearch
git checkout v7.9.3
./gradlew assemble
ls -la distribution/archives