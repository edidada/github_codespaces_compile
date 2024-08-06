#!/bin/bash
cd "$(dirname "$0")"
sudo apt-get update
sudo apt-get install -y libgl1-mesa-dev
git clone https://github.com/openscenegraph/OpenSceneGraph.git
cd OpenSceneGraph
git checkout OpenSceneGraph-3.6.2
cmake .
make
sudo make install