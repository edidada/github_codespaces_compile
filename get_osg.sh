#!/bin/bash
cd "$(dirname "$0")"
sudo apt update
git clone https://github.com/openscenegraph/OpenSceneGraph.git
cd OpenSceneGraph
git checkout OpenSceneGraph-3.6.2
cmake .
make
sudo make install