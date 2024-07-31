#!/bin/bash
cd "$(dirname "$0")"
sudo apt update
git clone https://github.com/charmber/Cppserve.git
cd Cppserve
git checkout 395b0cd5e42813dc968a7942b430a372d8365253
cmake -S . -B build
cmake --build